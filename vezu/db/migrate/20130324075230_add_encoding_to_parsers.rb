class AddEncodingToParsers < ActiveRecord::Migration
  def change
    add_column :parsers, :encoding, :string
  end
end
