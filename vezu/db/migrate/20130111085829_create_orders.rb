class CreateOrders < ActiveRecord::Migration
  def change
    create_table :orders do |t|
      t.string :ip
      t.string :page
      t.text :content
      t.string :total
      
      t.timestamps
    end
  end
end
