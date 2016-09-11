class ReplaceRanksWithHits < ActiveRecord::Migration
  def up
    remove_column :categories, :rank
    remove_column :subcategories, :rank
    add_column :categories, :hits, :integer, :default => 0
    add_column :subcategories, :hits, :integer, :default => 0
    add_column :firms, :hits, :integer, :default => 0
    add_column :items, :hits, :integer, :default => 0
  end

  def down
  end
end