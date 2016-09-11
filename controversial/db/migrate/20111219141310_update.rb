class Update < ActiveRecord::Migration
  def self.up
    drop_table :labels
    
    remove_column :fights, :ip
    remove_column :fights, :temporary
    add_column    :fights, :question, :string
    add_column    :fights, :description, :text
    
    
    remove_column :brands, :title
    remove_column :brands, :description
    add_column    :brands, :verb, :string
    add_column    :brands, :header, :string
    
  end

  def self.down
  end
end
