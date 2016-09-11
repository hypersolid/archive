class Ladder < ActiveRecord::Base
  belongs_to :tournament
  belongs_to :user
  has_many :prizes, :through => :tournament

  belongs_to :wing1, :class_name => 'Ladder'
  belongs_to :wing2, :class_name => 'Ladder'

  default_scope :order => "combined_score desc, set_at"
  scope :moved_at, lambda { |changed_at| joins(:user).where(:ladders => {:position_changed_at => changed_at})}

  delegate :leader, :leader, :to => :user

  def count_combined_score(*avg)
    score + wings.map(&:score).sum + (2 - wings_count) * (avg.empty? ? tournament.avg_score : avg[0]) 
  end

  def update_combined_score
    update_attribute :combined_score, count_combined_score
  end

  def question_stats
    stats_total = Answer.joins(:question).where(:answers => {:tournament_id=>1, :user_id=>6}).group('questions.category_id').select('questions.category_id category_id, count(answers.id) total').order('total DESC').limit(4)
    stats_wrong = Answer.joins(:question).where(:answers => {:tournament_id=>1, :user_id=>6, :points => 0}, :questions => {:category_id => stats_total.map(&:category_id)}).group('questions.category_id').select('questions.category_id category_id, count(answers.id) total')

    total = {}
    wrong = {}
    results = []

    stats_total.each {|item| total[item.category_id] = item.total}
    stats_wrong.each {|item| wrong[item.category_id] = item.total}

    total.each do |k, v|
      results << [Category.find(k).name, ((1 - wrong[k] / Float(v)) * 100).round(1)]
    end

    results
  end

  def next_ladder
    Ladder.where(:position => self.position - 1, :tournament_id => self.tournament.id).first
  end

  def next_prize
    tournament.prizes.where("position < #{self.position}").last
  end

  def next_prize_ladder
    tournament.ladders.where(:position => next_prize.position).first if next_prize
  end

  def wingmen_score
    combined_score - score
  end

  def wings
    [wing1, wing2].compact
  end

  def push
    Pusher["ladder-#{Rails.env}"].trigger('ladder-update', {:row_id => self.id, :old_position => self.position_old, :new_position => self.position, :score => self.combined_score})
  end

  def position_change
    (self.position_old - self.position).abs
  end

  def update_wings
    active = user.wingmen
    pending = user.pending_wingmen
    self.wing1, self.wing2 = active.map(&:ladder).compact
    self.wings_count = active.size + pending.size
    self.save :validate => false
  end

  # calculate possible benefits from invited wingmen
  def possible_benefit_from_wingmen
    l = self.tournament.ladders.where(["combined_score < ?", score * 3]).first
    l.nil? ? {:prize => 0} : {:position => l.position, :score => score * 3, :prize => l.prize}
  end

  # user has invited no wingmen AND the user is not winning any money AND the statement would deliver some prize
  def can_benefit_from_wingmen?
    user.all_wingmen.size == 0 && prize == 0 && possible_benefit_from_wingmen[:prize] > 0
  end
end