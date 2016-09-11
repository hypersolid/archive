class AddTextBiasToStations < ActiveRecord::Migration
  def change
    add_column :stations, :text_bias, :float
  end
end
