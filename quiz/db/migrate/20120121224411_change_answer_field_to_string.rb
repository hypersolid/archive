class ChangeAnswerFieldToString < ActiveRecord::Migration
  def self.up
    remove_column :answers, :answer
    add_column :answers, :answer, :string
  end

  def self.down
    remove_column :answers, :answer
    add_column :answers, :answer, :integer
  end
end
