class AddHitsToRoutes < ActiveRecord::Migration
  def change
    add_column :routes, :hits, :integer, :default => 0
  end
end
