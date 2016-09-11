class AddWingsToLadder < ActiveRecord::Migration
  def self.up
    add_column :ladders, :wings_count, :integer, :default => 0
    add_column :ladders, :wing1_id, :integer
    add_column :ladders, :wing2_id, :integer
    ActiveRecord::Base.transaction do
      Ladder.all.each {|l| l.update_wings}
    end
  end

  def self.down
    remove_column :ladders, :wings_count
    remove_column :ladders, :wing1_id
    remove_column :ladders, :wing2_id
  end
end
