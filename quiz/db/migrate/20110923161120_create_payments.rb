class CreatePayments < ActiveRecord::Migration
  def self.up
    create_table :payments do |t|
      t.integer :quiz_id
      t.string :status
      t.string :transaction_id
      t.text :query_string

      t.timestamps
    end
  end

  def self.down
    drop_table :payments
  end
end
