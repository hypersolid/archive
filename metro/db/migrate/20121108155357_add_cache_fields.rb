class AddCacheFields < ActiveRecord::Migration
  def change
    add_column :stations, :nearest_id, :integer
    add_column :stations, :x, :float
    add_column :stations, :y, :float
    add_column :stations, :tx, :float
    add_column :stations, :ty, :float
    add_column :stations, :transit, :boolean
    add_column :stations, :color, :string
    
    add_column :connections, :color, :string
    add_column :connections, :bezier, :string
  end
end
