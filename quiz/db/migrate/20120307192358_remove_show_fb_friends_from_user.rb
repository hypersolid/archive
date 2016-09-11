class RemoveShowFbFriendsFromUser < ActiveRecord::Migration
  def self.up
    remove_column :users, :show_only_facebook_friends
  end

  def self.down
    add_column :users, :show_only_facebook_friends, :boolean, :default => false
  end
end
