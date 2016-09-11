class AddMoreSettingsToGames < ActiveRecord::Migration
  def self.up
    add_column :games, :best_time_bonus, :integer
    add_column :games, :avg_time_bonus, :integer
    add_column :games, :points_per_second, :integer
  end

  def self.down
    remove_column :games, :best_time_bonus, :avg_time_bonus, :points_per_second
  end
end
