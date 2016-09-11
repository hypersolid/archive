class AddDefaultTimeSettings < ActiveRecord::Migration
  def self.up
    change_column :questions, :best_time, :float, :default => nil
    change_column :questions, :avg_time, :float, :default => nil
    Question.update_all "best_time=NULL"
    Question.update_all "avg_time=NULL"

    add_column :tournaments, :default_best_time, :integer, :default => 10
    add_column :tournaments, :default_avg_time, :integer, :default => 20
  end

  def self.down
    change_column :questions, :best_time, :float, :default => 10.0
    change_column :questions, :avg_time, :float, :default => 20.0

    remove_column :tournaments, :default_avg_time, :default_best_time
  end
end
