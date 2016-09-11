class CreateWallMessages < ActiveRecord::Migration
  def self.up
    create_table :wall_messages do |t|
      t.integer :sender_id
      t.integer :recipient_id
      t.string  :text 
      
      t.timestamps
    end
    add_index :wall_messages, [:sender_id, :recipient_id]
  end

  def self.down
    drop_table :wall_messages
  end
end
