class AddStateToRelation < ActiveRecord::Migration
  def self.up
    add_column :relations, :state, :string
    Relation.all.each { |r| r.update_attributes!(:state => 'revoked') }
  end

  def self.down
    remove_column :relations, :state
  end
end
