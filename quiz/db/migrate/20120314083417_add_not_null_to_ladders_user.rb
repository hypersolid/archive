class AddNotNullToLaddersUser < ActiveRecord::Migration
  def self.up
    change_column :ladders, :user_id, :integer, :null => :false
  end

  def self.down
    change_column :ladders, :user_id, :integer, :null => :true
  end
end
