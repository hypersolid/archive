class CreateLinesStationsTable < ActiveRecord::Migration
  def up
    create_table :lines_stations do |t|
      t.integer :station_id
      t.integer :line_id

      t.integer :city_id

      t.timestamps
    end
    add_index :lines_stations, :city_id
    add_index :lines_stations, [:station_id, :line_id], :unique=>true
  end

  def down
    remove_index :lines_stations, :city_id
    remove_index :lines_stations, [:station_id, :line_id]
    drop_table :lines_stations
  end
end
