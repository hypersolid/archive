class AddTypeAndEmailToRelation < ActiveRecord::Migration
  def self.up
    add_column :relations, :invited_by, :string
    add_column :relations, :email, :string
    Relation.all.each { |r| r.update_attributes!(:invited_by => 'facebook') }
  end

  def self.down
    remove_column :relations, :invited_by
    remove_column :relations, :email
  end
end
