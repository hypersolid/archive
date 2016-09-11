class CreateQuestions < ActiveRecord::Migration
  def self.up
    create_table :questions do |t|
      t.integer :difficulty
      t.integer :category_id
      t.string :question
      t.string :answer1
      t.string :answer2
      t.string :answer3
      t.string :answer4
      t.integer :correct_answer

      t.timestamps
    end

    add_index :questions, :id, :unique => true
  end

  def self.down
    drop_table :questions
  end
end
