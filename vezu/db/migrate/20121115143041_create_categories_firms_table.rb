class CreateCategoriesFirmsTable < ActiveRecord::Migration
  def up
    create_table :categories_firms do |t|
      t.integer :category_id
      t.integer :firm_id
    end
  end

  def down
    drop_table :categories_firms
  end
end
