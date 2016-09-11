class AddAvgScoreToGames < ActiveRecord::Migration
  def self.up
    add_column :games, :avg_score, :integer, :default => 0
  end

  def self.down
    remove_column :games, :avg_score
  end
end
