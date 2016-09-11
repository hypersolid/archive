class CreateFights < ActiveRecord::Migration
  def self.up
    create_table :fights do |t|
      t.string :title
      t.string :slug

      t.timestamps
    end
    add_index :fights, :slug
  end

  def self.down
    drop_table :fights
  end
end
