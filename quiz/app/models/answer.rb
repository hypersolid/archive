class Answer < ActiveRecord::Base
  belongs_to :question
  belongs_to :user
  belongs_to :tournament
  belongs_to :quiz

  def self.count_with_difficulty(difficulty)
    self.first(
          :group => :user_id, 
          :select => "*, count(user_id) AS answer_count",
          :joins => :question,
          :conditions => ["questions.difficulty = ?", difficulty],
          :order => "answer_count DESC"
    ).answer_count rescue 0
  end
end
