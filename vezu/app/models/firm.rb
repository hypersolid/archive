# encoding: utf-8

class Firm < ActiveRecord::Base
  attr_protected
  
  has_attached_file :img, :styles => { :thumb => "170x120#", :tiny => "58x40#" }, :storage => :s3, :s3_credentials => "#{Rails.root.to_s}/config/s3.yml",:path => "/firms/:style/:id/:filename"
  # rake paperclip:refresh:thumbnails CLASS=Firm
  
  has_many :items
  has_many :subcategories, :through => :items, :uniq => true
  has_many :categories, :through => :subcategories, :uniq => true
  has_many :parsers
  
  scope :by_hits, :order=>'firms.hits desc'
  
  def top(category, limit=3)
    Item.includes(:subcategory).where(['subcategories.category_id = ? AND items.firm_id = ?', category.id, self.id]).all(:limit=>limit, :order => 'random()')
  end
  
  def items_by_category(c)
    self.items.includes(:subcategory).where('subcategories.category_id = ?',c.id).all
  end
  
  def items_by_subcategory(sc)
    self.items.by_hits.where('subcategory_id = ?', sc.id).all
  end
  
  def average_price(c)
    return nil if c.name == 'Напитки' 
    is = items_by_category(c)
    weights = is.map{|i| (i.weight.to_f rescue nil)}.compact
    prices = is.map{|i| (i.price.to_f rescue nil)}.compact
    if prices.size > 0 && weights.size > 0 && weights.sum > 0 
      (prices.sum/prices.count) / (weights.sum/weights.count)
    else
      nil
    end 
  end
  
  def count_subcategories_in_category(c)
    self.items.includes(:subcategory).where('subcategories.category_id = ?', c.id).map{|i| i.subcategory.id}.uniq.size
  end
  
  def closed
    !self.opened
  end
  
  def opened
    pairs = self.openinghours.split(',').map{|r| r.strip.split(' ').map(&:strip)}
    pairs.each do |p|
       return true if Firm.opened_time(p[0], p[1])
    end
    false
  end
  
  def self.opened_day(days, shift = 0)
    days = Unicode::downcase(days)
    aliases = ['вс', 'пн', 'вт', 'ср', 'чт', 'пт', 'сб']
    day = Time.now.in_time_zone.wday + shift.days
    
    return true if days == 'ежедневно'
    return true if !days.include?('-') && aliases.index(days) == day
    if days.include?('-')
      days = days.split('-')
      from = aliases.index(days.first)
      to = aliases.index(days.last)
      return true if to > from && day >= from && day <= to
      return true if to < from && day >= from || day <= to   
    end
    false
  end
  
  def self.opened_time(day, period)
    return true if period == 'круглосуточно' && Firm.opened_day(day)
    time = Time.zone.now
    period = period.split('-').map(&:strip)
    from = Time.zone.parse(period.first)
    to = Time.zone.parse(period.last)
    midnight =  Time.zone.parse('00:00')
    
    if to > from
      time >= from && time <= to && Firm.opened_day(day)
    else
      (time >= from && time <= midnight + 1.day) && Firm.opened_day(day) || (time >= midnight && time <= to) && Firm.opened_day(day, -1)
    end
  end

  def hit!; self.update_attribute(:hits, self.hits + 1); end
  
  def url
    '/всё/' + self.name
  end
end
