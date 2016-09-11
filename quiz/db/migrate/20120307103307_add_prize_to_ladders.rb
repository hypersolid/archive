class AddPrizeToLadders < ActiveRecord::Migration
  def self.up
    add_column :ladders, :prize, :integer, :default => 0
    Tournament.current.refresh_scores! if Tournament.current
  end

  def self.down
    remove_column :ladders, :prize
  end
end
