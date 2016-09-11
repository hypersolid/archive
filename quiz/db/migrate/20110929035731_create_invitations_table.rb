class CreateInvitationsTable < ActiveRecord::Migration
  def self.up
    create_table :invitations do |t|
      t.integer :user_id
      t.integer :friend_id
      t.string  :request_id
      t.integer :game_id
      t.string  :status

      t.timestamps
    end    
  end

  def self.down
    drop_table :invitations
  end
end
