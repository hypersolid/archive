class ChangeTournamentsCredits < ActiveRecord::Migration
  def self.up
    remove_column :tournaments, :credits
    add_column :tournaments, :existing_user_credits, :integer, :default => 0
    add_column :tournaments, :new_user_credits, :integer, :default => 0    
  end

  def self.down
    add_column :tournaments, :credits, :integer, :default => 1
    remove_column :tournaments, :existing_user_credits, :new_user_credits
  end
end
