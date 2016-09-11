class CreateVotes < ActiveRecord::Migration
  def self.up
    create_table :votes do |t|
      t.integer :brand_id
      t.string :meta1
      t.string :meta2
      t.string :meta3
      t.timestamps
    end
  end

  def self.down
    drop_table :votes
  end
end
