class CreateLadders < ActiveRecord::Migration
  def self.up
    create_table :ladders do |t|
      t.integer :game_id
      t.integer :user_id
      t.integer :position
      t.integer :score, :default => 0
      t.integer :combined_score, :default => 0
      t.timestamps
    end
  end

  def self.down
    drop_table :ladders
  end
end
