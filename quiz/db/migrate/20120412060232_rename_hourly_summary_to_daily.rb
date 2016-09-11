class RenameHourlySummaryToDaily < ActiveRecord::Migration
  def self.up
    rename_column :users, :email_hourly_summary, :email_daily_summary
  end

  def self.down
    rename_column :users, :email_daily_summary, :email_hourly_summary
  end
end
