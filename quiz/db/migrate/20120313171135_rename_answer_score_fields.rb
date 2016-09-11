class RenameAnswerScoreFields < ActiveRecord::Migration
  def self.up
    rename_column :answers, :points, :claimed_points
    rename_column :answers,  :time_points, :acquired_points
  end

  def self.down
    rename_column :answers, :claimed_points, :points
    rename_column :answers, :acquired_points, :time_points 
  end
end
