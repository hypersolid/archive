class AddTournamentIdToRelations < ActiveRecord::Migration
  def self.up
    add_column :relations, :tournament_id, :integer, :null => false
    Relation.update_all :tournament_id => Tournament.current.id rescue nil
  end

  def self.down
    remove_column :relations, :tournament_id
  end
end
