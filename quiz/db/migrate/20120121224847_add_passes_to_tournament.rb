class AddPassesToTournament < ActiveRecord::Migration
  def self.up
    add_column :tournaments, :passes, :integer, :default => 2
  end

  def self.down
    remove_column :tournaments, :passes
  end
end
