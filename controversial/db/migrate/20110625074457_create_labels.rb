class CreateLabels < ActiveRecord::Migration
  def self.up
    create_table :labels do |t|
      t.integer :brand_id
      t.string :title
      t.integer :votes,:default=>1
    end
    add_index :labels, :brand_id
    add_index :labels, :title
  end

  def self.down
    drop_table :labels
  end
end
