class CreateEmailFallbacks < ActiveRecord::Migration
  def self.up
    create_table :email_fallbacks do |t|
      t.string :from
      t.string :to
      t.string :subject
      t.text   :body
      t.timestamps
    end
  end

  def self.down
    drop_table :email_fallbacks
  end
end
