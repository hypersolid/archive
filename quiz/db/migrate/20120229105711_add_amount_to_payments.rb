class AddAmountToPayments < ActiveRecord::Migration
  def self.up
    add_column :payments, :amount, :decimal, :precision => 8, :scale => 2
  end

  def self.down
    remove_column :payments, :amount
  end
end
