class AddStatusToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :status_message, :string
  end

  def self.down
    remove_column :users, :status_message
  end
end
