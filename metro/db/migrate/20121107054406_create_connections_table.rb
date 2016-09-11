class CreateConnectionsTable < ActiveRecord::Migration
  def up
    create_table :connections do |t|
      t.integer :station_id
      t.integer :target_id

      t.integer :line_id
      t.integer :city_id
  
      t.float :distance

      t.timestamps
    end
    add_index :connections, :city_id
    add_index :connections, :line_id
    add_index :connections, [:station_id, :target_id], :unique => true
  end

  def down
    remove_index :connections, :city_id
    remove_index :connections, :line_id
    remove_index :connections, [:station_id, :target_id]
    drop_table :connections
  end
end
