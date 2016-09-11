class CreateFactsTable < ActiveRecord::Migration
  def self.up
    create_table :facts do |t|
      t.integer :brand_id
      t.string :text
      t.timestamps
    end
    add_index :facts, :brand_id
  end

  def self.down
    drop_table :facts
  end
end