class ChangeLivesToCredits < ActiveRecord::Migration
  def self.up
    rename_column :tournaments, :lives, :credits
    add_column :users, :credits, :integer, :default => 0
    remove_column :quizzes, :paid
    rename_column :payments, :quiz_id, :user_id

    User.update_all "credits=1"
  end

  def self.down
    rename_column :tournaments, :credits, :lives
    remove_column :users, :credits
    add_column :quizzes, :paid, :boolean
    rename_column :payments, :user_id, :quiz_id
  end
end
