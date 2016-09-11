class AddTimePointsToAnswers < ActiveRecord::Migration
  def self.up
    add_column :answers, :time_points, :integer
  end

  def self.down
    remove_column :answers, :time_points
  end
end
