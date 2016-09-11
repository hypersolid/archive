class AddScaleToCity < ActiveRecord::Migration
  def change
    add_column :cities, :scale, :float
    add_column :cities, :offset, :string
  end
end
