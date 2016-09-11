class AddSetAtToLadders < ActiveRecord::Migration
  def self.up
    add_column :ladders, :set_at, :datetime
  end

  def self.down
    remove_column :ladders, :set_at
  end
end
