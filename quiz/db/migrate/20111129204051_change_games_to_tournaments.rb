class ChangeGamesToTournaments < ActiveRecord::Migration
  def self.up
    rename_table :games, :tournaments
    rename_table :game_counters, :tournament_counters

    rename_column :answers, :game_id, :tournament_id
    rename_column :tournament_counters, :game_id, :tournament_id
    rename_column :ladders, :game_id, :tournament_id
    rename_column :prizes, :game_id, :tournament_id
    rename_column :quizzes, :game_id, :tournament_id
    rename_column :relations, :game_id, :tournament_id
  end

  def self.down
    rename_column :answers, :tournament_id, :game_id
    rename_column :tournament_counters, :tournament_id, :game_id
    rename_column :ladders, :tournament_id, :game_id
    rename_column :prizes, :tournament_id, :game_id
    rename_column :quizzes, :tournament_id, :game_id
    rename_column :relations, :tournament_id, :game_id

    rename_table :tournaments, :games
    rename_table :tournament_counters, :game_counters
  end
end
