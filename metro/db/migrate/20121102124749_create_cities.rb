class CreateCities < ActiveRecord::Migration
  def up
    create_table :cities do |t|
      t.string :city_name, :null => false
      t.string :local_name
      t.string :full_name
      t.string :metro_name
      t.string :country, :null => false

      t.float :lat
      t.float :lon
      t.string :bounds
    
      t.string :openinghours
      t.text :description
      t.text :fares
      t.string :openingyear
      t.integer :nstations
      t.integer :length

      t.boolean :public, :default => false

      t.timestamps
    end
    add_index :cities, [:city_name, :country], :unique => true
    add_index :cities, :public
  end

  def down
    remove_index :cities, [:city_name, :country]
    drop_table :cities
  end
end
