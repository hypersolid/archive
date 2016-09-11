class AddEmailMangementFieldsToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :email_up_the_ladder, :boolean, :default => true
    add_column :users, :email_hourly_summary, :boolean, :default => true
    add_column :users, :email_final_summary, :boolean, :default => true
    add_column :users, :email_wingman_request_accepted, :boolean, :default => true
  end

  def self.down
    remove_column :users, :email_up_the_ladder
    remove_column :users, :email_hourly_summary
    remove_column :users, :email_final_summary
    remove_column :users, :email_wingman_request_accepted
  end
end
