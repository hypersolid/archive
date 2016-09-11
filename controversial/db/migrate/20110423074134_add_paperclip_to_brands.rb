class AddPaperclipToBrands < ActiveRecord::Migration
  def self.up
    add_column :brands, :img_file_name,    :string
    add_column :brands, :img_content_type, :string
    add_column :brands, :img_file_size,    :integer
    add_column :brands, :img_updated_at,   :datetime
    add_column :brands, :avatar_file_name,    :string
    add_column :brands, :avatar_content_type, :string
    add_column :brands, :avatar_file_size,    :integer
    add_column :brands, :avatar_updated_at,   :datetime
  end

  def self.down
    remove_column :brands, :img_file_name
    remove_column :brands, :img_content_type
    remove_column :brands, :img_file_size
    remove_column :brands, :img_updated_at
    remove_column :brands, :avatar_file_name
    remove_column :brands, :avatar_content_type
    remove_column :brands, :avatar_file_size
    remove_column :brands, :avatar_updated_at
  end
end