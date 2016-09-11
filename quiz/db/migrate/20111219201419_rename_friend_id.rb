class RenameFriendId < ActiveRecord::Migration
  def self.up
    rename_column :relations, :friend_id, :wingman_id
  end

  def self.down
    rename_column :relations, :wingman_id, :friend_id
  end
end
