class AddQuizIdToAnswer < ActiveRecord::Migration
  def self.up
    add_column :answers, :quiz_id, :integer
  end

  def self.down
    remove_column :answers, :quiz_id
  end
end
