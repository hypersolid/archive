class CreateFacebookFriends < ActiveRecord::Migration
  def self.up
    create_table :facebook_friends do |t|
      t.integer :user_id, :null => false
      t.integer :friend_id  
      t.integer :facebook_uid, :limit => 8, :null => false 
    end
    add_index :facebook_friends, [:user_id, :facebook_uid], :unique => true
  end

  def self.down
    remove_index :facebook_friends, [:user_id, :facebook_uid]
    drop_table :facebook_friends
  end
end
