class CreateBrands < ActiveRecord::Migration
  def self.up
    create_table :brands do |t|
      t.integer :fight_id
      t.string :title
      t.integer :votes_stored,:default=>0
      t.integer :votes_count,:default=>0

      t.timestamps
    end
    
    add_index :brands, :fight_id
  end

  def self.down
    drop_table :brands
  end
end
