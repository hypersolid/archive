class AddTimeLagToAnswers < ActiveRecord::Migration
  def self.up
    add_column :answers, :time_lag, :float
  end

  def self.down
    remove_column :answers, :time_lag
  end
end