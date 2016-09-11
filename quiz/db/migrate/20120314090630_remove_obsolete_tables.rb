class RemoveObsoleteTables < ActiveRecord::Migration
  def self.up
    drop_table :ladder_logs
    drop_table :achievements
    drop_table :live_updates
  end

  def self.down
  end
end
