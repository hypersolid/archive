class Question < ActiveRecord::Base
  belongs_to :category
  belongs_to :best_user, :class_name => "User"

  has_many :answers
  has_many :users, :through => :answers

  validates_presence_of :difficulty, :question, :correct_answer
  validate :wrong_answers_count

  scope :with_difficulty, lambda {|difficulty| where("difficulty = ?", difficulty) if difficulty }
  scope :for, lambda {|user| where("id NOT IN (?)", user.questions) unless user.questions.empty? }

  # override avg and best time with default settings
  def avg_time
    self[:avg_time] || Tournament.current.default_avg_time
  end

  def best_time
    self[:best_time] || Tournament.current.default_best_time
  end

  def wrong_answers=(answers)
    answers = answers.split("\n") if answers.is_a?(String)
    write_attribute(:wrong_answers, answers.map(&:strip).uniq.to_json)
  end

  def wrong_answers
    ActiveSupport::JSON.decode(read_attribute(:wrong_answers)) rescue []
  end

  def wrong_answers_text
    wrong_answers.join("\r\n")
  end

  def wrong_answers_html
    wrong_answers.join("<br />")
  end

  def randomised_answers
    (wrong_answers.sample(2) << correct_answer).shuffle
  end

  private
  def wrong_answers_count
     errors.add(:wrong_answers, "field can not contain less than 2 answers") unless wrong_answers.size >= 2
  end

end
