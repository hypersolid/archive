class CreateItemsOrdersTable < ActiveRecord::Migration
  def up
    create_table :items_orders do |t|
      t.integer :item_id
      t.integer :order_id
    end
  end

  def down
    drop_table :items_orders
  end
end
