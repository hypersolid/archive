class ChangeAnswers < ActiveRecord::Migration
  def self.up
    add_column :answers, :time, :integer
    add_column :answers, :points, :integer
  end

  def self.down
    remove_column :answers, :time, :points
  end
end
