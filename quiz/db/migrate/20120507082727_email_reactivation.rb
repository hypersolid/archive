class EmailReactivation < ActiveRecord::Migration
  def self.up
    remove_column :users, :email_up_the_ladder
    remove_column :ladders, :position_tournament_best
    remove_column :ladders, :position_current_best

    rename_column :users, :email_daily_summary, :email_movement    
    add_column :ladders, :position_old, :integer
    add_column :ladders, :position_changed_at, :datetime
  end

  def self.down
    add_column :users, :email_up_the_ladder, :boolean, :default => true
    add_column :ladders, :position_tournament_best, :integer
    add_column :ladders, :position_current_best, :integer
    
    rename_column :users, :email_movement, :email_daily_summary
    remove_column :ladders, :position_old
    remove_column :ladders, :position_changed_at
  end
end
