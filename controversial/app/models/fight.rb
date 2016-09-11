class Fight < ActiveRecord::Base
  belongs_to :brand1, :class_name => 'Brand', :foreign_key => 'brand1_id' 
  belongs_to :brand2, :class_name => 'Brand', :foreign_key => 'brand2_id' 
  
  after_create :create_brands
  before_save :update_title
  
  acts_as_taggable
  
  scope :main,  :order=>'created_at desc', 
                    :limit=>1, 
                    :conditions => {:featured=>true}
                    
  scope :fresh,     :order=>'created_at desc'
                    
  scope :trend,     :order=>"votes desc"
                    
  scope :random,    :order=>"RAND()"

  def url
    "/#{slug.blank? ? id : slug}"
  end
  
  def brand_ids
    [brand1_id, brand2_id]
  end
  def brands
    [brand1, brand2]
  end
    
  def prev
    Fight.all(:order=>'id desc',:limit=>1,:conditions=>['id<?',self.id]).first
  end
  def next
    Fight.all(:order=>'id',:limit=>1,:conditions=>['id>?',self.id]).first
  end
  

  
  def featured=(_featured)
    if _featured
     ActiveRecord::Base.connection.execute('update fights set featured=false')
    end
    write_attribute(:featured, _featured)
  end
  
  def find_brand_by_slug(url)
     return brand1 if brand1.id.to_s == url || brand1.url == url
     return brand2 if brand2.id.to_s == url || brand2.url == url
     return nil  
  end
  
  #view helpers
  def short_title
    (title.blank? ? 'New topic' : title).strip.capitalize
  end
  def full_title
    unless title.blank?
      "#{title}. #{question}: #{brand1.humanize_verb} or #{brand2.humanize_verb}?"
    else
      "New controversial issue or topic"
    end
  end
  def full_votes
    case votes
    when 0
      "no votes"
    when 1
      "one vote"
    else
      "#{votes} votes"
    end
  end
  def full_description
    description.blank? ? 'This controversial issue has a long history ...' : description
  end
  
  private
  def create_brands
    self.brand1 = Brand.create(:fight => self)
    self.brand2 = Brand.create(:fight => self)
    self.save
  end
  def update_title
    self.slug = self.title.blank? ? self.id.to_s : self.title.strip.downcase.gsub(/[^[:alnum:]]/,'-').gsub(/-{2,}/,'-')
  end
  
  #for the future use
  def related
    Fight.find_tagged_with(tag_list).select{|f| f.id!=self.id}.sort_by(&:votes).reverse
  end
end
