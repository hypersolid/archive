class Relation < ActiveRecord::Base
  belongs_to :wingman, :class_name => "User"
  belongs_to :tournament
  belongs_to :user

  validates_uniqueness_of :request_id
  # validate :maximum_relations_for_user

  after_save :update_ladder_counter
  after_destroy :update_ladder_counter
  after_create :add_bonus

  #TODO: add valitation before create if user already has 2 pending or active Relations

  include AASM
  aasm :column => :state do  # defaults to aasm_state
    state :pending, :initial => true
    state :active
    state :revoked

    event :accept do
      transitions :to => :active, :from => [:pending], :guard => :can_be_accepted?
    end

    event :revoke do
      transitions :to => :revoked, :from => [:active, :pending, :revoked], :guard => :can_be_revoked?
    end
  end

  def can_be_accepted?
    tournament.active? && !wingman.have_played_quiz? && user.get_wingmen(:active).count < 2
  end

  def can_be_revoked?
    revoked? || pending? || active? && !wingman.have_played_quiz?
  end

  def accept_relation(user)
    # self.user.increment!(:credits, 2)
    # EmailFallback.proxy(:bonus_credits, self.user, self.wingman) if self.user.get_wingmen(:active).count == 2

    self.wingman = user
    begin
      self.accept!
      if !self.user.email.blank? && self.user.email_wingman_request_accepted?
        EmailFallback.proxy(:wingman_request_accepted, self.user, self.wingman)
      end
      Pusher["ladder-#{Rails.env}"].trigger('wingmen-update', {:user_id => self.user_id}) unless Rails.env.test?
    rescue AASM::InvalidTransition
      self.revoke!
    end
  end

  # find pending FB relation or create new pending FB relation if possible
  def self.find_or_create_pending_fb_relation(user_id)
    conditions = {:tournament_id => Tournament.current.id, :state => "pending", :invited_by => "facebook", :wingman_id => nil, :user_id => user_id}
    Relation.where(conditions).first || (Relation.create!(conditions.merge(:request_id => Devise.friendly_token[0,30])) if User.find(user_id).can_send_invites?)
  end

  # find revoked and pending relations which should have been connected to users having corresponding emails
  def self.find_broken
    user_emails = User.all.map(&:email)
    self.where(:tournament_id => Tournament.current.id, :state => ["revoked", "pending"], :invited_by => "email").all.delete_if{|r| !r.email.in?(user_emails)}
  end

  private
  def update_ladder_counter
    user.ladder.update_wings if user && user.ladder
  end
  
  def maximum_relations_for_user
    tournament_ok = (Tournament.current && Tournament.current.active?)
    count_ok = (user.all_wingmen.reject{|r| r.id == self.id}.count < 2)
    state_ok = (self.state == "revoked")
    errors.add(:user, 'already has 2 wingmen in current tournament') unless tournament_ok && count_ok || state_ok  
  end

  def add_bonus
    user.increment!(:credits, 2) if user.get_wingmen.count <= 2
  end
end
