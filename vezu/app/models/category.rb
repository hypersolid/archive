# encoding: utf-8

class Category < ActiveRecord::Base
  attr_protected
  
  has_attached_file :img, 
                    :styles => { :medium => "150x150#", :thumb => "100x100#", :tiny => "50x50#"}, 
                    :storage => :s3,
                    :s3_credentials => "#{Rails.root.to_s}/config/s3.yml", :path => "/categories/:style/:id/:filename"
  
  has_many :subcategories
  has_many :items, :through => :subcategories
  has_many :firms, :through => :items, :uniq => true
  
  scope :by_hits, :order=>'categories.hits desc'
  
  def empty?
    self.items.count == 0
  end
  
  def downcase
    n = self.name
    n = 'Пиццу' if n == 'Пицца'
    Unicode::downcase(n) 
  end
  
  def downcase2
    n = self.name
    list = { "Пицца"=>"пиццы",
    "Закуски"=>"закусок",
    "Соусы"=>"соусов",
    "Супы"=>"супов",
    "Второе"=>"второго",
    "Сеты"=>"сетов",
    "Десерты"=>"десертов",
    "Пироги"=>"пирогов",
    "Салаты"=>"салатов",
    "Блюда на мангале"=>"блюд на мангале",
    "Роллы"=>"роллов"
    }
    n = list[n] if list[n]
    Unicode::downcase(n)
  end
  
  def hit!; self.update_attribute(:hits, self.hits + 1); end
end
