namespace :performance do
  desc "Various test tasks"

  task :spawn_questions => :environment do
    quantity = 1000
    ActiveRecord::Base.transaction do
      quantity.times do |i|
        Question.create(:difficulty => (i % 5 + 1))
      end
    end
  end

  task :spawn_users => :environment do
    tournament = Tournament.current
    quantity = 1000
    factor_quizzes = 5
    factor_answers = 5
    ActiveRecord::Base.transaction do
      quantity.times do |i|
        u = User.create(:email => "anderson#{quantity - i}@example.com", :name => "Mr. Anderson ##{quantity - i}", :password => 'quizquiz', :password_confirmation => 'quizquiz')
        Ladder.create(:user => u, :score => 100 * i, :combined_score => 100 * i, :tournament => tournament, :position => quantity - i, :set_at => Time.now - Random.rand(500).hours)
        factor_quizzes.times do
          q = Quiz.create(:tournament => tournament, :user => u)
          factor_quizzes.times do
            Answer.create(:tournament => tournament, :user => u, :quiz => q, :question => Question.first(:order => 'RAND()'))  
          end  
        end
      end
    end
    ActiveRecord::Base.transaction do
      (User.count / 3).round.times do |i|
        id1 = User.first(:order => 'RAND()').id
        id2 = User.where('id != ?', id1).first(:order => 'RAND()').id
        Relation.create(:user_id => id1, :wingman_id => id2, :state => ["active","pending"].sample(1)[0], :request_id => i.to_s)  
      end
    end
  end

  task :recall_users => :environment do
    ActiveRecord::Base.transaction do
      User.where(["users.email like ?", '%example.com']).destroy_all
    end
  end

end