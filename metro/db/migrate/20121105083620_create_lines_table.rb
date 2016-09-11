class CreateLinesTable < ActiveRecord::Migration
  def up
    create_table :lines do |t|
      t.integer :city_id, :null => false
      
      t.string :name
      t.string :name_local
      
      t.string :color
      t.string :style
      
      t.timestamps
    end
    add_index :lines, :city_id
  end

  def down
    remove_index :lines, :city_id
    drop_table :lines
  end
end
