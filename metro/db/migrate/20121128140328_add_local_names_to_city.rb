class AddLocalNamesToCity < ActiveRecord::Migration
  def change
    add_column :cities, :local_names, :boolean, :default => true
  end
end
