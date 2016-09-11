class ChangeQuestionsDefaultTimes < ActiveRecord::Migration
  def self.up
    change_column :questions, :best_time, :float, :default => 10
    change_column :questions, :avg_time, :float, :default => 20
  end

  def self.down
    change_column :questions, :best_time, :float
    change_column :questions, :avg_time, :float    
  end
end
