class CreateItemsTable < ActiveRecord::Migration
  def up
    create_table :items do |t|
      t.string :name
      t.string :description
      t.string :note
      t.integer :price
      
      t.integer :category_id
      t.integer :firm_id

      t.timestamps
    end
  end

  def down
    drop_table :items
  end
end
