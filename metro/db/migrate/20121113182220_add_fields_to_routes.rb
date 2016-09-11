class AddFieldsToRoutes < ActiveRecord::Migration
  def change
    add_column :routes, :distance, :float
    add_column :routes, :html, :text
  end
end
