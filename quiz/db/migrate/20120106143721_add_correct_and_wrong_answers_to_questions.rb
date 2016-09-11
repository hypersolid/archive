class AddCorrectAndWrongAnswersToQuestions < ActiveRecord::Migration
  def self.up
    remove_column :questions, :correct_answer
    remove_column :questions, :answer1
    remove_column :questions, :answer2
    remove_column :questions, :answer3
    remove_column :questions, :answer4
    
    add_column :questions, :correct_answer, :string
    add_column :questions, :wrong_answers,  :string
    
    Question.destroy_all
  end

  def self.down
    remove_column :questions, :correct_answer
    remove_column :questions, :wrong_answers
    
    add_column :questions, :correct_answer, :integer
    add_column :questions, :answer1, :string
    add_column :questions, :answer2, :string
    add_column :questions, :answer3, :string
    add_column :questions, :answer4, :string
  end
end