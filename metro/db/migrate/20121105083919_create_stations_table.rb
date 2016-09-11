class CreateStationsTable < ActiveRecord::Migration
  def up
    create_table :stations do |t|
      t.integer :city_id

      t.string :name
      t.string :name_local
      
      t.float :lat
      t.float :lon

      t.timestamps
    end
    add_index :stations, :city_id
  end

  def down
    remove_index :stations, :city_id
    drop_table :stations
  end
end
