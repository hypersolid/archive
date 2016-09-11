class AddObsoleteToItem < ActiveRecord::Migration
  def change
    add_column :items, :obsolete, :boolean, :default => true
  end
end
