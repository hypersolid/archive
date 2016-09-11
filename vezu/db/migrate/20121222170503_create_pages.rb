class CreatePages < ActiveRecord::Migration
  def change
    create_table :pages do |t|
      t.string :slug, :null => false
      t.string :header
      t.text :content
      t.timestamps
    end
    add_index :pages, :slug, :uniq => true
  end
end
