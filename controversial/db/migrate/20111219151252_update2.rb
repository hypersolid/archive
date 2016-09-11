class Update2 < ActiveRecord::Migration
  def self.up
    add_column    :fights, :brand1_id, :integer
    add_column    :fights, :brand2_id, :integer
    remove_column :brands, :avatar_file_name
    remove_column :brands, :avatar_content_type
    remove_column :brands, :avatar_file_size
    remove_column :brands, :avatar_updated_at
  end

  def self.down

  end
end
