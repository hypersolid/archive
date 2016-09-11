class AddFeaturedToFight < ActiveRecord::Migration
  def self.up
    add_column :fights, :featured, :boolean, :default=>false
  end

  def self.down
    remove_column :fights, :featured
  end
end
