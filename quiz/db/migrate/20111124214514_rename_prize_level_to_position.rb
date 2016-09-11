class RenamePrizeLevelToPosition < ActiveRecord::Migration
  def self.up
    rename_column :prizes, :level, :position
  end

  def self.down
    rename_column :prizes, :position, :level
  end
end
