class Tournament < ActiveRecord::Base
  has_many :ladders, :order => "combined_score desc, set_at", :autosave => true
  has_many :users, :through => :ladders
  has_many :answers
  has_many :quizzes
  has_many :relations

  has_many :prizes, :order => "position"
  accepts_nested_attributes_for :prizes, :reject_if => lambda { |p| p[:amount].blank? }

  has_many :tournament_counters, :order => "created_at"
  accepts_nested_attributes_for :tournament_counters

  default_scope order("ends_at, created_at DESC")

  validates_presence_of :best_time_bonus, :avg_time_bonus, :points_per_second
  validate :date_validator

  # advanced validations
  def date_validator
    # errors.add(:starts_at, "conflicts with existing tournament") unless Tournament.all(:conditions => ["(:starts_at BETWEEN starts_at AND ends_at) OR (:ends_at BETWEEN starts_at AND ends_at) OR (starts_at BETWEEN :starts_at AND :ends_at)",
    #   {:starts_at  => starts_at, :ends_at => ends_at }]
    # ).delete_if{|g| g == self}.empty?

    errors.add(:ends_at, "should be after the start date") if ends_at < starts_at
    errors.add(:ends_at, "tournament should last at least 1 day") if ends_at - starts_at < 1.day
  end

  def self.current
    first(:conditions => ["? BETWEEN starts_at AND ends_at", Time.now]) or last(:conditions => ["? > ends_at", Time.now])
  end

  def active?
    starts_at <= Time.now && ends_at >= Time.now
  end

  # get 10 ladders near the given ladder
  def ladders_near(l)
    position_range = (l.position-9)..(l.position+9)
    count = self.ladders.where(:position => position_range).count
    offset = (count > 10 ? count - 10 : 0)/2
    self.ladders.where(:position => position_range).limit(10).offset(offset).all
  end

  # override avg_score database value:
  # return either a database value or zero depending on the deploy_average_scoring admin setting
  def avg_score
    deploy_average_scoring? ? self[:avg_score] : 0
  end

  # calculate difficulty for the given question number in the sequence
  def difficulty(n)
    return nil if tournament_counters.empty?

    for i in 0..(tournament_counters.size - 1)
      return tournament_counters[i].difficulty if tournament_counters.map(&:counter)[0..i].sum >= n + 1
    end

    return tournament_counters.last.difficulty
  end

  def prize_for(n)
    prizes.where(:position => n).first.amount rescue 0
  end

  def closest_prize_for(n)
    prize = prizes.where(["position < ?", n]).last
  end


  def time_left
    t = ends_at - Time.now
    if t > 0
      mm, ss = t.divmod(60)
      hh, mm = mm.divmod(60)
      dd, hh = hh.divmod(24)
      {:days => dd, :hours => hh, :minutes => mm, :seconds => ss.round}
    end
  end

  def points_total
   time_limit * points_per_second
  end

  def points_max
    points_total + best_time_bonus + avg_time_bonus
  end

  def points_to_time(points)
    return time_limit * (Float(points) / points_total)
  end

  def points_with_bonuses(user, question, points)
    elapsed_time = time_limit - points_to_time(points)
    if question.avg_time.nil? || elapsed_time < question.avg_time
      points += avg_time_bonus
    end
    if question.best_time.nil? || elapsed_time < question.best_time
      points += best_time_bonus
      question.update_attributes!(:best_time => elapsed_time, :best_user => user)
    end
    return points
  end

  def self.total_payout_to_date
    find(:all, :select => :amount, :conditions => ["? > ends_at", Time.now], :joins => :prizes).map(&:amount).sum
  end

  def send_final_summary!
    return if active? || ends_at < 1.hour.ago

    self.ladders.each do |l|
      if !l.user.email.blank? && l.user.email_final_summary?
        EmailFallback.proxy(:final_summary, l)
      end
    end
  end

  def send_invite_wingmen
    if active?
      ladders.each do |l|
        EmailFallback.proxy(:invite_wingmen, l.user) if l.wings == 0
      end
    end
  end

  # Crucial ladder update functions
  def refresh_scores!(full = true)
    if full
      avg = ladders.average(:score).to_i
      if avg != self.avg_score
        self.avg_score = avg
        self.update_scores
      end
    end

    changed_at = self.update_positions
    ActiveRecord::Base.transaction { self.save :validate => false }
    changed_at
  end

  def winners
    ladders.map{|l| "Place: " + l.position.to_s + ", Prize: " + l.prize.to_s + ", Email: " + l.user.email + (l.user.real_name.blank? ? "" : ", Real Name: " + l.user.real_name + ", Address: " + l.user.address + " " + l.user.post_code) if l.prize > 0}.compact.join("\n")
  end

  protected
  def update_scores
    mapping = {}
    ladders.each {|l| mapping[l.id] = l.score}
    ladders.size.times do |i|
      wingmen_score = 0
      wingmen_score += mapping[ladders[i-1].wing1_id] if ladders[i-1].wing1_id && mapping[ladders[i-1].wing1_id]
      wingmen_score += mapping[ladders[i-1].wing2_id] if ladders[i-1].wing2_id && mapping[ladders[i-1].wing2_id]  
      average_score = (2 - ladders[i-1].wings_count) * avg_score
      ladders[i-1].combined_score = ladders[i-1].score + wingmen_score + average_score 
    end
    ladders.sort!{|a,b| a.combined_score != b.combined_score ? b.combined_score <=> a.combined_score : a.set_at <=> b.set_at}
  end

  def update_positions(changed_at = nil)
    changed_at = eval("Time.now.utc")
    positions = ladders.map(&:position)
    # if position numbers aren't ordered
    unless positions == Array(1..ladders.size)
      # create array of prizes
      prizes_array = Array.new(ladders.size, 0)
      prizes.each {|prize| prizes_array[prize.position - 1] = prize.amount}
  
      # update position numbers
      for new_position in 1..ladders.size
        old_position = ladders[new_position-1].position
        ladders[new_position-1].position = new_position
        ladders[new_position-1].prize = prizes_array[new_position-1]

        if new_position != old_position
          ladders[new_position-1].position_old = old_position
          ladders[new_position-1].position_changed_at = changed_at
          # update up & down flags
          if new_position < old_position
            ladders[new_position-1].up = true
            ladders[new_position-1].down = false
          else
            ladders[new_position-1].up = false
            ladders[new_position-1].down = true
          end
        end
      end
    end
    changed_at
  end

  # revoke automatically created pending FB relations if they were not activated for 1 hour
  def self.revoke_pending_fb_relations!
    Relation.where(:state => "pending", :invited_by => "facebook", :wingman_id => nil, :created_at => 1.year.ago..1.hour.ago).each{|r| r.revoke!}
  end
end