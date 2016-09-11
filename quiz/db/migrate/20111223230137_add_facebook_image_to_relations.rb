class AddFacebookImageToRelations < ActiveRecord::Migration
  def self.up
    add_column :relations, :facebook_image_url, :string
  end

  def self.down
    remove_column :relations, :facebook_image_url
  end
end
