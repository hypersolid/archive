class RenameThresholdsToDeliveryConditions < ActiveRecord::Migration
  def up
    remove_column :firms, :threshold
    remove_column :firms, :threshold_int
    remove_column :firms, :delivery_time
    add_column :firms, :conditions, :text
  end

  def down
  end
end
