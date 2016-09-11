namespace :update do
  desc "update questions"
  task :questions => :environment do
    require "csv"
    id = 1
    (CSV.read("db/questions.csv") + CSV.read("db/questions2.csv")).each do |difficulty, category_name, question, answer1, answer2, answer3, correct_answer|
      wrong   = [answer1, answer2, answer3].compact.delete_if{|a| a.upcase == correct_answer.upcase}
      correct = ([answer1, answer2, answer3].compact - wrong).first

      q = Question.find(id)
      q.update_attributes!(
        :question => question.force_encoding('utf-8'),
        :correct_answer => correct.force_encoding('utf-8'),
        :wrong_answers => wrong.map{|a| a.force_encoding('utf-8')}
      )
      id += 1
    end
  end
end
