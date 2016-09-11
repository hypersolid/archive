class CreateQuizzes < ActiveRecord::Migration
  def self.up
    create_table :quizzes do |t|
      t.integer :user_id
      t.integer :game_id
      t.boolean :paid

      t.timestamps
    end
  end

  def self.down
    drop_table :quizzes
  end
end
