class Answers < ActiveRecord::Migration
  def self.up
    create_table :answers do |t|
      t.integer  :question_id
      t.integer  :user_id
      t.integer  :game_id
      t.integer  :answer
      t.timestamps
    end

    add_index :answers, :user_id
    add_index :answers, :question_id
  end

  def self.down
    drop_table :answers
  end
end
