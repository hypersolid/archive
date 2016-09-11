class AddPayloadToEntries < ActiveRecord::Migration
  def change
    add_column :entries, :payload, :json
  end
end
