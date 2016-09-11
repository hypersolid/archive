class AddModeToPayments < ActiveRecord::Migration
  def self.up
    add_column :payments, :mode, :string
  end

  def self.down
    remove_column :payments, :mode
  end
end
