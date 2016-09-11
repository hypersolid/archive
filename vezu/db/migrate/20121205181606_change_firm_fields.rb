class ChangeFirmFields < ActiveRecord::Migration
  def up
    remove_column :firms, :address
    add_column :firms, :threshold_int, :integer
    add_column :firms, :delivery_time, :integer
  end

  def down
  end
end
