class AddBestPositionsToLadders < ActiveRecord::Migration
  def self.up
    add_column :ladders, :position_tournament_best, :integer
    add_column :ladders, :position_current_best, :integer
  end

  def self.down
    remove_column :ladders, :position_tournament_best
    remove_column :ladders, :position_current_best
  end
end
