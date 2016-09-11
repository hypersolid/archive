class ChangeWeightToString < ActiveRecord::Migration
  def up
    change_column :items, :weight, :string
  end

  def down
  end
end
