# encoding: utf-8
class User < ActiveRecord::Base
  include ActionView::Helpers::NumberHelper
  include ActionView::Helpers::RawOutputHelper
  include ApplicationHelper

  # Include default devise modules. Others available are:
  # :token_authenticatable, :encryptable, :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :omniauthable

  has_many :authentications

  # Setup accessible (or protected) attributes for your model
  # attr_accessible *(self.column_names - [:encrypted_password, :reset_password_token, :admin, :credits])
  attr_protected :encrypted_password, :reset_password_token, :admin, :credits

  has_many :ladders, :dependent => :destroy
  has_many :tournaments, :through => :ladders

  has_many :answers, :dependent => :destroy
  has_many :questions, :through => :answers

  has_many :quizzes, :dependent => :destroy
  has_many :payments

  has_many :relations
  has_many :facebook_friends, :foreign_key => :user_id, :dependent => :destroy
  has_many :friends, :through => :facebook_friends

  has_many :wall_messages, :foreign_key => :recipient_id, :order => 'created_at DESC'

  validates_uniqueness_of :email
  validates_presence_of :name

  has_attached_file :avatar,
                    :styles => { :medium => "300x300#" },
                    :default_style => :medium,
                    :default_url => '/images/shared/anybody.jpg'

  after_destroy :cleanup_relations

  # find current ladder
  def ladder
    Tournament.current.ladders.where(:user_id => self.id).first
  end

  def new_user?
   created_at > Tournament.current.starts_at
  end

  # existing users did not play quiz in current tournament yet
  def existing_user_needs_credits?
    !new_user? && !have_played_quiz?
  end

  def have_played_quiz?
    quizzes.where(:tournament_id => Tournament.current).exists?
  end

  def has_played_one_quiz?
    quizzes.where(:tournament_id => Tournament.current).count == 1
  end

  def has_played_only_one_quiz?
    quizzes.count == 1
  end

  def self.find_for_facebook_oauth(access_token)
    data = access_token[:extra][:raw_info]
    if user = User.find_by_email(data[:email])
      user.update_attribute :facebook_uid, data[:id]
      user
    else # Create a user with a stub password.
      User.create!(:facebook_uid => data[:id], :email => data[:email], :name => data[:name], :gender => data[:gender], :password => Devise.friendly_token[0,20])
    end
  end

  def leader
    Relation.where(:wingman_id => self.id, :state => "active", :tournament_id => Tournament.current.id).first.user rescue nil
  end

  def wingman1
    wingmen.empty? ? nil : wingmen.first
  end

  def wingman2
    wingmen.size == 2 ? wingmen.last : nil
  end

  def update_score(val)
    ladder.update_attribute :score, val
  end

  def wingmen_ladders
    wingmen.map{|w| w ? w.ladder : nil}
  end

  def wingmen_ids
    get_wingmen(:active).map(&:wingman_id)
  end

  def was_invited?
    Relation.exists?(:wingman_id => self.id, :state => "active", :tournament_id => Tournament.current.id)
  end

  def show_popup_invite?
    result = (popup_invite && (quizzes.count == Tournament.current.new_user_credits) && relations.count == 0)
    update_attribute :popup_invite, false if result
    result
  end

  def prize_total
    ladders.map(&:prize).flatten.sum
  end

  ########################### WINGMEN FILTERS & COUNTERS ##################################################
  def get_wingmen(*states)
    tournament = Tournament.current
    states = %w(active pending revoked) if states.empty? # return all states by default
    relations.where("relations.state in (?) and relations.tournament_id = ?", states, tournament.id)
  end

  def wingmen
    get_wingmen(:active).map(&:wingman)
  end

  def pending_wingmen
    get_wingmen(:pending)
  end

  def all_wingmen
    get_wingmen(:active, :pending).map{|r| r.active? ? r.wingman : r}
  end

  def invites_left
    2 - all_wingmen.count
  end
  
  def can_send_invites?
    invites_left > 0
  end

  def can_get_bonus?
    get_wingmen.count < 2
  end
  #########################################################################################################

  def with_team
    [self] + wingmen
  end

  def with_friends
    [self] + friends
  end

  def update_friends(facebook_uids)
    facebook_uids.each do |uid|
      link = self.facebook_friends.where(:facebook_uid => uid).first
      friend = User.find_by_facebook_uid(uid)
      
      if link && friend && link.friend != friend 
        link.update_attribute :friend_id, friend.id
      elsif !link && friend
        self.facebook_friends.create(:friend => friend, :facebook_uid => uid)
      elsif !link && !friend
        self.facebook_friends.create(:facebook_uid => uid)   
      end

    end
  end

  def facebook_image
    authentications.find(:last, :conditions => "image IS NOT NULL").image rescue nil
  end

  def time_lag_deviation(tournament)
    return '' unless tournament
    time_lags = answers.where(:tournament_id => tournament.id).map(&:time_lag).compact
    unless time_lags.empty?
      global_average = Answer.average(:time_lag)
      local_average = time_lags.sum / time_lags.count
      percent = (local_average / global_average * 100).round
      "#{percent - 200}%" if percent > 200
    end
  end

  def unlink_facebook
    if facebook_uid && !email.blank?
      facebook_friends.destroy_all
      authentications.destroy_all
      update_attribute :facebook_uid, nil
    else
      false
    end
  end

  def pays?
    return false if admin?
    return quizzes.count >= (new_user? ? Tournament.current.new_user_credits : Tournament.current.existing_user_credits)
  end

  def should_play_quiz?
    !quizzes.exists? && Tournament.current.active? && Tournament.current.new_user_credits > 0
  end

  def nudge_wingman(wingman_id, amount, message)
    if credits >= amount && wingmen_ids.include?(wingman_id.to_i)
      wingman = User.find(wingman_id)
      ActiveRecord::Base.transaction do
        self.decrement!(:credits, amount)
        wingman.increment!(:credits, amount)
      end
      EmailFallback.proxy(:nudge_friend_email, self, wingman, message, amount)
    end
  end

  def post_fb_feed(ladder)
    return if last_fb_post_at && last_fb_post_at > 48.hours.ago

    message = "#{name} has moved up the Game Show General Knowledge ladder to #{ladder.position.ordinalize} place"
    message << " and is currently winning #{pounds(ladder.prize).sub(/&pound;/, "£")}. Join in at http://www.gameshow.co.uk !"

    client = FBGraph::Client.new(:client_id => facebook_uid, :token => token)
    result = client.selection.me.feed.publish!(:message => message) rescue nil
    update_attribute(:last_fb_post_at, Time.now) if result
    result
  end

  private
  def cleanup_relations
    Relation.where("user_id = ? or wingman_id = ?", self.id, self.id).destroy_all
  end
end