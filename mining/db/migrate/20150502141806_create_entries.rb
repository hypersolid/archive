class CreateEntries < ActiveRecord::Migration
  def change
    create_table :entries do |t|
      t.column :title, :string
      t.column :summary, :text
      t.column :url, :string
      t.column :source, :string
      t.column :published, :datetime
    end

    add_index :entries, :url, unique: true
  end
end
