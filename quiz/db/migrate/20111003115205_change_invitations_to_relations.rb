class ChangeInvitationsToRelations < ActiveRecord::Migration
  def self.up
    rename_table :invitations, :relations
  end

  def self.down
    rename_table :relations, :invitations
  end
end
