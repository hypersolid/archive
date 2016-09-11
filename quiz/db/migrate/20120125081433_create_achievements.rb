class CreateAchievements < ActiveRecord::Migration
  def self.up
    create_table :achievements do |t|
      t.string :label
    end
    add_index :achievements, :label, :unique => true
  end

  def self.down
    drop_table :achievements
  end
end
