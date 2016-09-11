# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).

exit if Rails.env.test?

if User.count == 0 
  User.create!(:name => "Vitaly", :email => "fomichov@gmail.com", :password => 'quiz2011', :password_confirmation => 'quiz2011')
  User.create!(:name => "Jamie", :email => "jamie.murraywells@glassesdirect.com", :password => 'quiz2011', :password_confirmation => 'quiz2011')
  User.create!(:name => "Anton", :email => "antonlaptew@gmail.com", :password => 'quiz2011', :password_confirmation => 'quiz2011')
  User.create!(:name => "Alexander", :email => "akrasnoschekov@gmail.com", :password => 'quiz2011', :password_confirmation => 'quiz2011')
  
  # grant admin privileges
  User.update_all "admin=1"
end

if Tournament.count == 0
  Tournament.create!(:starts_at => Time.now, :ends_at => 1.day.from_now, :time_limit => 30, :best_time_bonus => 500, :avg_time_bonus => 250, :points_per_second => 100)
end

if Question.count == 0
  # import questions
  require "csv"
  (CSV.read("db/questions1.csv") + CSV.read("db/questions2.csv"+ CSV.read("db/questions3.csv")).each do |difficulty, category_name, question, answer1, answer2, answer3, correct_answer|
    category = Category.find_or_create_by_name(category_name)
  
    wrong   = [answer1, answer2, answer3].compact.delete_if{|a| a.upcase == correct_answer.upcase}
    correct = ([answer1, answer2, answer3].compact - wrong).first
  
    Question.create!(
      :difficulty => difficulty,
      :category => category,
      :question => question.force_encoding('utf-8'),
      :correct_answer => correct.force_encoding('utf-8'),
      :wrong_answers => wrong.map{|a| a.force_encoding('utf-8')}
    )
  end
end

# add +1 credit
User.update_all "credits=1"