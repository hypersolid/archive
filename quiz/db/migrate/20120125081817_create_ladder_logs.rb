class CreateLadderLogs < ActiveRecord::Migration
  def self.up
    create_table :ladder_logs do |t|
      t.integer :ladder_id
      t.integer :position
      t.integer :score   
      t.integer :combined_score 
      
      t.datetime :created_at
    end
    add_index :ladder_logs, :ladder_id
  end

  def self.down
    drop_table :ladder_logs
  end
end
