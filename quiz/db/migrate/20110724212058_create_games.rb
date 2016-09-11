class CreateGames < ActiveRecord::Migration
  def self.up
    create_table :games do |t|
      t.integer :time_limit
      t.string  :difficulty_counters
      t.datetime :starts_at
      t.datetime :ends_at
      t.timestamps
    end
  end

  def self.down
    drop_table :games
  end
end
