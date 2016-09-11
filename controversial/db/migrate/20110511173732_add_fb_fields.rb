class AddFbFields < ActiveRecord::Migration
  def self.up
    add_column :brands, :description, :text
    add_column :fights, :temporary, :boolean, :default=>false
    add_column :fights, :ip, :string
  end

  def self.down
    remove_column :brands, :description
    remove_column :fights, :temporary
    remove_column :fights, :ip
  end
end
