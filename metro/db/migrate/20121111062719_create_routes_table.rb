class CreateRoutesTable < ActiveRecord::Migration
  def up
    create_table :routes do |t|
      t.integer :city_id, :null => false

      t.integer :source_id, :null => false
      t.integer :destination_id, :null => false
      
      t.text :nodes  
      t.text :edges

      t.timestamps
    end
    add_index :routes, :city_id
    add_index :routes, [:source_id, :destination_id]
  end

  def down
    remove_index :routes, :city_id
    remove_index :routes, [:source_id, :destination_id]
    drop_table :routes    
  end
end
