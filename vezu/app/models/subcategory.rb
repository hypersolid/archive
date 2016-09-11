class Subcategory < ActiveRecord::Base
  attr_protected
  
  belongs_to :category
  has_many :items
  
  scope :by_hits, :order=>'subcategories.hits desc'
  
  def full_name
    "#{self.category.name rescue 'Empty'} - #{self.name}"
  end
  
  def hit!; self.update_attribute(:hits, self.hits + 1); end
end
