class RemoveStatusFromRelation < ActiveRecord::Migration
  def self.up
    remove_column :relations, :status
  end

  def self.down
    add_column :relations, :status, :string
    Relation.destroy_all
  end
end
