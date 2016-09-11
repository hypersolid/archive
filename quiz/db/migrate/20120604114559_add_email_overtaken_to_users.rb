class AddEmailOvertakenToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :email_overtaken, :boolean, :default => true
  end

  def self.down
    remove_column :users, :email_overtaken
  end
end
