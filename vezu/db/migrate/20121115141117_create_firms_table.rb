class CreateFirmsTable < ActiveRecord::Migration
  def up
    create_table :firms do |t|
      t.string :name
      t.string :address
      t.string :description
      t.string :phones
      t.string :site
      t.string :social_vk
      t.string :social_fb
      
      t.integer :threshold
      t.string :exceptions
      t.string :openinghours

      t.timestamps
    end
  end

  def down
    drop_table :categories
  end
end
