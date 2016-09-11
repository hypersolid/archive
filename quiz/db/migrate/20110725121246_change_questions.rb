class ChangeQuestions < ActiveRecord::Migration
  def self.up
    add_column :questions, :avg_time, :integer
    add_column :questions, :best_time, :integer
    add_column :questions, :best_user_id, :integer
  end

  def self.down
    remove_column :questions, :avg_time, :best_time, :best_user_id
  end
end
