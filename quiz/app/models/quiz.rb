class Quiz < ActiveRecord::Base
  belongs_to :user
  belongs_to :tournament
  has_many :answers
  has_one :payment

  scope :paid, where(:paid => 1)
  scope :free, where(:paid => 0)

  def question_number
    answers.count + 1
  end

  def questions_answered
    answers.count
  end

  def passes_left
    tournament.passes - answers.map(&:answer).count(nil)
  end

end
