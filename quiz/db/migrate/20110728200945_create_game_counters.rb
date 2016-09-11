class CreateGameCounters < ActiveRecord::Migration
  def self.up
    create_table :game_counters do |t|
      t.integer :game_id
      t.integer :counter
      t.integer :difficulty
      t.timestamps
    end

    remove_column :games, :difficulty_counters
  end

  def self.down
    drop_table :game_counters
    add_column :games, :difficulty_counters, :string
  end
end
