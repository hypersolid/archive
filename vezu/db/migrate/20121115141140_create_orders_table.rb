class CreateOrdersTable < ActiveRecord::Migration
  def up
    create_table :orders do |t|
      t.string :number
      
      t.string :address
      t.string :latlon
      t.string :note
      
      t.integer :total
      
      t.integer :firm_id
      
      t.string :result

      t.timestamps
    end
  end

  def down
    drop_table :orders
  end
end
