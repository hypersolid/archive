class AddCodeToParsers < ActiveRecord::Migration
  def change
    add_column :parsers, :code, :text
  end
end
