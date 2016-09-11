class AddPopupInviteToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :popup_invite, :boolean, :default => true
  end

  def self.down
    remove_column :users, :popup_invite
  end
end
