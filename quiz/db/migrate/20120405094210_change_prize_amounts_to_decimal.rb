class ChangePrizeAmountsToDecimal < ActiveRecord::Migration
  def self.up
    change_column :prizes, :amount, :decimal, :precision => 8, :scale => 2    
    change_column :ladders, :prize, :decimal, :precision => 8, :scale => 2, :default => 0
  end

  def self.down
    change_column :prizes, :amount, :integer
    change_column :ladders, :prize, :integer, :default => 0
  end
end
