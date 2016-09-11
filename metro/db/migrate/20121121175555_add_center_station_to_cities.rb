class AddCenterStationToCities < ActiveRecord::Migration
  def change
    add_column :cities, :center_station_id, :integer
  end
end