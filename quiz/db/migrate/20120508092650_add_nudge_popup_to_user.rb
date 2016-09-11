class AddNudgePopupToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :popup_nudge, :boolean, :default => true
  end

  def self.down
    remove_column :users, :popup_nudge
  end
end
