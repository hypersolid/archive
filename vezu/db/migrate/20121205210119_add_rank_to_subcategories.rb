class AddRankToSubcategories < ActiveRecord::Migration
  def change
    add_column :subcategories, :rank, :integer
  end
end
