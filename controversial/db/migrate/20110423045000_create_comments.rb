class CreateComments < ActiveRecord::Migration
  def self.up
    create_table :comments do |t|
      t.string :text
      t.integer :votes
      t.integer :brand_id

      t.timestamps
    end
    add_index :comments, :brand_id
  end

  def self.down
    drop_table :comments
  end
end
