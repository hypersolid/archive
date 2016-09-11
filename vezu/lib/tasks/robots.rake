require 'nokogiri'
require 'net/http'
require 'uri'
def get(url, enc)
  uri = URI.parse(url)
  result = Net::HTTP.start(uri.host, uri.port) {|http|
    http.get(uri.request_uri)
  }
  result.body.force_encoding('CP1251') unless enc.blank?
  result.body
end
def get_binding(pk);return binding;end

namespace :robots  do
  task :parse => :environment do
    p = Parser.find(ENV['PID'])
    firm = p.firm
    p.firm.items.map{|v| v.update_attribute(:obsolete, true)}

    p.urls.split("\r\n").each do |url|
      params = url.strip.split('|')
      uri = params[2]
      root_modifier = params[3]
      category = Category.find_or_create_by_name(params[0])
      subcategory = Subcategory.all(:conditions => {:category_id => category.id, :name => params[1]}).first
      subcategory = Subcategory.create({:category => category, :name => params[1]}) unless subcategory

      items = Item.all(:conditions => {:subcategory_id => subcategory.id, :firm_id => firm.id})
    
      puts '=========================='
      puts "##{subcategory.id} #{category.name}.#{subcategory.name} #{items.count} items"
      puts "=> Parsing '#{firm.name}' #{url}"
      puts '=========================='
      
      doc = Nokogiri::HTML(get(uri, p.encoding))
      nodes = doc.xpath(p.root+root_modifier.to_s)
      puts "#{nodes.count} items"
      
      amount = (Rails.env == "development" ? 1 : 100)
      nodes[0,amount].each do |item|
        src = (item.xpath(p.src).first.attr('src').to_s.strip rescue nil)
        name = item.xpath(p.name).first.text.gsub(//,'').strip
        desc = (item.xpath(p.description).first.content.strip.gsub(/\s+/,' ') rescue nil)
        weight = (item.xpath(p.weight).first.text.to_i rescue nil)
        price = (item.xpath(p.price).first.text.to_i rescue nil)
        
        pack = {:price => price, :weight => weight, :name => name, :description => desc, :source => src} 
        
        if p.code
          pack = eval(p.code + ";pk", get_binding(pack))
        end
        
        i = Item.all(:conditions => {:firm_id => firm.id, :subcategory_id => subcategory.id, :name => pack[:name]}).first
        i = Item.new() unless i
        
        i.name = pack[:name]
        i.price = pack[:price]
        i.weight = pack[:weight]
        i.description = pack[:description]
        
        i.firm = firm
        i.subcategory = subcategory
        
        i.img_from_url(pack[:source]) if pack[:source] rescue nil
        
        i.obsolete = false
        i.save
        
        p i
      end
    end    
    Item.where(:obsolete=>true).destroy_all
  end

end