class AddEmailWallMesssageToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :email_wall_message, :boolean, :default => true
  end

  def self.down
    remove_column :users, :email_wall_message
  end
end
