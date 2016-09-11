class CreateAchievementsLadders < ActiveRecord::Migration
  def self.up
    create_table(:achievements_ladders, :id => false) do |t|
      t.integer :achievement_id
      t.integer :ladder_id
      t.datetime :created_at
    end
    add_index :achievements_ladders, [:ladder_id, :achievement_id]
  end

  def self.down
    drop_table :achievements_ladders
  end
end
