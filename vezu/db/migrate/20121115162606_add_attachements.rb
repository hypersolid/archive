class AddAttachements < ActiveRecord::Migration
  def up
    change_table :categories do |t|
      t.has_attached_file :img
    end
    change_table :firms do |t|
      t.has_attached_file :img
    end
    change_table :items do |t|
      t.has_attached_file :img
    end
  end

  def down
    drop_attached_file :categories, :img
    drop_attached_file :firms, :img
    drop_attached_file :items, :img
  end
end
