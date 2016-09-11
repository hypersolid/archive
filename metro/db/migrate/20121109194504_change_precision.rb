class ChangePrecision < ActiveRecord::Migration
  def up
    change_column :stations, :lat, :decimal, :precision => 18, :scale => 12
    change_column :stations, :lon, :decimal, :precision => 18, :scale => 12
  end

  def down
    change_column :stations, :lat, :float
    change_column :stations, :lon, :float
  end
end