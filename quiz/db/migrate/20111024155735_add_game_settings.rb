class AddGameSettings < ActiveRecord::Migration
  def self.up
    add_column :games, :deploy_average_scoring, :boolean, :default => true
    add_column :games, :lives, :integer, :default => 1
    add_column :games, :cost_pence, :integer, :default => 100
  end

  def self.down
    remove_column :games, :deploy_average_scoring, :lives, :cost_pence
  end
end
