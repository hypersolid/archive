class AddPaidToQuizzes < ActiveRecord::Migration
  def self.up
    add_column :quizzes, :paid, :boolean, :default => false
  end

  def self.down
    remove_column :quizzes, :paid
  end
end
