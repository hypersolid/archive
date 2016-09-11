class SwitchToSubcategories < ActiveRecord::Migration
  def up
    add_index     :subcategories, :category_id
    rename_column :items, :category_id, :subcategory_id
    add_index     :items, :subcategory_id
    add_index     :items, :firm_id
  end

  def down
  end
end
