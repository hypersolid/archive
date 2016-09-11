class AddNameToRelation < ActiveRecord::Migration
  def self.up
    add_column :relations, :name, :string
    Relation.all.each { |r| r.update_attributes!(:name => 'Invited Name') }
  end

  def self.down
    remove_column :relations, :name
  end
end
