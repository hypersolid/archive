class AddVotesToFight < ActiveRecord::Migration
  def self.up
    add_column :fights, :votes, :integer, :default=>0
  end

  def self.down
    remove_column :fights, :votes
  end
end
