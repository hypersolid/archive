class CreateLiveUpdates < ActiveRecord::Migration
  def self.up
    create_table(:live_updates, :id => false) do |t|
      t.integer :producer_id
      t.string :kind, :null => false
      t.string :params
      t.datetime :created_at
    end
    add_index :live_updates, :created_at
  end

  def self.down
    drop_table :live_updates
  end
end
