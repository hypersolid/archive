class ChangeTournamentsDefaultCredits < ActiveRecord::Migration
  def self.up
    change_column :tournaments, :new_user_credits, :integer, :default => 2
    Tournament.update_all(:new_user_credits => 2)
  end

  def self.down
    change_column :tournaments, :new_user_credits, :integer, :default => 0
  end
end
