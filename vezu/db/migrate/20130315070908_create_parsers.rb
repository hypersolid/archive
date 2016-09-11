class CreateParsers < ActiveRecord::Migration
  def change
    create_table :parsers do |t|
      t.integer :firm_id
      t.string :root
      t.string :src
      t.string :name
      t.string :description
      t.string :weight
      t.string :price
      t.text :urls
    end
  end
end
