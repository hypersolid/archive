class ChangeTimeFieldsToFloat < ActiveRecord::Migration
  def self.up
    remove_column :answers, :time
    remove_column :questions, :best_time
    remove_column :questions, :avg_time
    add_column :answers, :time, :float
    add_column :questions, :best_time, :float
    add_column :questions, :avg_time, :float
  end

  def self.down
    remove_column :answers, :time
    remove_column :questions, :best_time
    remove_column :questions, :avg_time
    add_column :answers, :time, :integer
    add_column :questions, :best_time, :integer
    add_column :questions, :avg_time, :integer
  end
end
