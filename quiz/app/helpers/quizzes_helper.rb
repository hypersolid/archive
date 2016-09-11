module QuizzesHelper

  def quiz_correct_answer
    Rails.env.development? ? " (#{current_question.correct_answer})" : ""
  end

  def quiz_merge_bonuses
    current_question && (current_question.avg_time.nil? || current_question.best_time.round(2) == current_question.avg_time.round(2))
  end

  def q(str)
    str.gsub('\'','\\\\\'')
  end

  def rq(str)
    raw q(str)
  end

end