class AddLastFbPostToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :last_fb_post_at, :datetime
  end

  def self.down
    remove_column :users, :last_fb_post_at
  end
end
