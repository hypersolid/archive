class AddShowFbFriendsToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :show_only_facebook_friends, :boolean, :default => false
  end

  def self.down
    remove_column :users, :show_only_facebook_friends
  end
end
