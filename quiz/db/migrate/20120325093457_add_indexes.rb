class AddIndexes < ActiveRecord::Migration
  def self.up
    add_index :authentications, [:user_id, :image]
    add_index :email_fallbacks, :id

    add_index :ladders, :id
    add_index :ladders, [:tournament_id, :user_id]
    add_index :ladders, [:tournament_id, :position]

    add_index :payments, :user_id
    add_index :prizes, [:tournament_id, :position]
    add_index :quizzes, :user_id

    add_index :relations, [:user_id, :state]
    add_index :relations, [:wingman_id, :state]
    add_index :tournament_counters, :tournament_id
    add_index :tournaments, :id
  end

  def self.down
    remove_index :authentications, [:user_id, :image]
    remove_index :email_fallbacks, :id

    remove_index :ladders, :id
    remove_index :ladders, [:tournament_id, :user_id]
    remove_index :ladders, [:tournament_id, :position]

    remove_index :payments, :user_id
    remove_index :prizes, [:tournament_id, :position]
    remove_index :quizzes, :user_id

    remove_index :relations, [:user_id, :state]
    remove_index :relations, [:wingman_id, :state]
    remove_index :tournament_counters, :tournament_id
    remove_index :tournaments, :id
  end
end