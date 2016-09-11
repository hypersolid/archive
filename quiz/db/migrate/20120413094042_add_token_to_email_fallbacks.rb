class AddTokenToEmailFallbacks < ActiveRecord::Migration
  def self.up
    add_column :email_fallbacks, :token, :string, :null => false
    add_index  :email_fallbacks, :token
  end

  def self.down
    remove_index  :email_fallbacks, :token
    remove_column :email_fallbacks, :token
  end
end
