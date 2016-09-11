class AddWeightToItems < ActiveRecord::Migration
  def change
    add_column :items, :weight, :integer
  end
end
