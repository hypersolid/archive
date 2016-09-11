class AddUpAndDownFlagsToLadders < ActiveRecord::Migration
  def self.up
    add_column :ladders, :up, :boolean
    add_column :ladders, :down, :boolean
  end

  def self.down
    remove_column :ladders, :up, :down
  end
end
