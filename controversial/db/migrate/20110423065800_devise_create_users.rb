class DeviseCreateUsers < ActiveRecord::Migration
  def self.up
    create_table(:users) do |t|
      t.database_authenticatable :null => false
      t.rememberable
      t.trackable
      t.token_authenticatable

      t.timestamps
    end
    User.create(:email=>'sol@sol.com',:password=>'sol47')
    add_index :users, :email, :unique => true
  end

  def self.down
    drop_table :users
  end
end
