require "open-uri"

class Item < ActiveRecord::Base
  attr_protected
  
  before_create :process_name 
  
  has_attached_file :img, :styles => {:medium => "200x200>", :thumb => "100x100#", :tiny => "50x50#" }, :storage => :s3, :s3_credentials => "#{Rails.root.to_s}/config/s3.yml",:path => "/items/:style/:id/:filename"
  # rake paperclip:refresh:thumbnails CLASS=Item

  belongs_to :firm
  belongs_to :subcategory
  delegate :category, :to => :subcategory, :allow_nil => true
  
  scope :by_hits, :order=>'items.hits desc'
  
  def similar
    Item.includes(:subcategory).where("LOWER(items.name) = LOWER(?) and subcategories.category_id = ? and items.firm_id != ?", self.name, self.subcategory.category_id, self.firm_id).order('items.price')
  end
  
  def hit!; self.update_attribute(:hits, self.hits + 1); end
  
  #Item.all.each{|i| i.process_name;i.save}
  def process_name
    self.name = Unicode::capitalize(name.strip)
  end
  
  
  def img_from_url(url)
    self.img = open(url)
  end
end
