class DropObsoleteTables < ActiveRecord::Migration
  def up
    drop_table :orders
    drop_table :items_orders
    drop_table :categories_firms
  end

  def down
  end
end
