class AddAddressToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :real_name, :string
    add_column :users, :address, :string
    add_column :users, :post_code, :string
  end

  def self.down
    remove_column :users, :real_name
    remove_column :users, :address
    remove_column :users, :post_code
  end
end
