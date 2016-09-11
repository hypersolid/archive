class ChangeThresholdType < ActiveRecord::Migration
  def up
    change_column :firms, :threshold, :string
  end

  def down
  end
end
