class Brand < ActiveRecord::Base
  belongs_to :fight
  has_many :votes
  
  if Rails.env=='production'
    has_attached_file :img, 
            :styles => { :medium => ["350x350#", :jpg], :tiny => ["50x50#", :jpg]},
            :url => "http://media.controversialmatter.com/upload/imgs/:id/:style.:extension",
            :path => "/home/s74/public_html/media_controversialmatter/upload/imgs/:id/:style.:extension",
            :default_url => 'http://media.controversialmatter.com/images/design/img_missing_:style.jpg'
  else
    has_attached_file :img, 
            :styles => { :medium => ["350x350!", :jpg], :tiny => ["50x50!", :jpg]},
            :default_url => 'http://localhost/images/design/img_missing_:style.jpg'
  end    
    
  validates_attachment_content_type :img, :content_type=>['image/jpeg', 'image/png', 'image/gif']
   
  def humanize_verb
    verb.blank? ? 'None' : verb.capitalize
  end
    
  def rating
    if votes_stored
      votes_stored + votes_count
    else
      votes_count
    end  
  end
  
  def picture(size=:thumb)
    img.url(size)
  end
  
  def pair
    self.fight.brands.select{|b| b.id!=self.id}.first
  end

  def full_header
    unless header.blank?
      header
    else
      "I vote for '#{verb}', because ..."
    end
  end

  def url
    verb.blank? ? id.to_s : verb.strip.downcase.gsub(/[^[:alnum:]]/,'-').gsub(/-{2,}/,'-')
  end
end
