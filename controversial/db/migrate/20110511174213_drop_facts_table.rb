class DropFactsTable < ActiveRecord::Migration
  def self.up
    Brand.all.each do |b|
     b.description=b.facts[0,5].map{|f| '- '+f.text}.join('<br/>')
     b.save
    end
    drop_table :facts
    drop_table :comments
  end

  def self.down
  end
end
