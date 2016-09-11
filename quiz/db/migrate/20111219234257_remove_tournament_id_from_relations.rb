class RemoveTournamentIdFromRelations < ActiveRecord::Migration
  def self.up
    remove_column :relations, :tournament_id
  end

  def self.down
    add_column :relations, :tournament_id, :integer
  end
end
