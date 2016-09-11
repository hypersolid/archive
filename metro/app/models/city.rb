class City < ActiveRecord::Base
  has_many :lines
  has_many :stations
  has_many :connections
  has_many :routes
  belongs_to  :center_station, :class_name => Station

  scope :public, where(:public => true)

  #############################################################################
  # Getters
  #############################################################################

  def get_offset
    unless offset
      self.stations.map(&:get_xy)
      mx = self.stations.average(:x)
      my = self.stations.average(:y)
      self.update_attribute :offset, "#{mx},#{my}"
    end
    self.center_station_id ? self.center_station.get_xy.join(',') : self.offset  
  end

  #############################################################################
  # Maintenance
  #############################################################################

  def reflash
    #self.update_attributes({:offset=>nil})
    #self.reflash_stations
    #self.reflash_connections
    #self.routes.destroy_all
  end

  def reflash_stations
    self.stations.update_all({:color=>nil, :x=>nil, :y=>nil, :tx => nil, :ty=>nil, :nearest_id => nil, :transit => nil})
  end

  def reflash_connections
    self.connections.update_all({:bezier=>nil})
  end

  #############################################################################
  # Helpers
  #############################################################################
  
  def self.g(name)
    City.find_by_city_name(name)
  end

  def self.set_public(city_name)
    self.unscoped.find_by_city_name(city_name).update_attribute :public, true
  end
  
  def self.set_private(city_name)
    self.unscoped.find_by_city_name(city_name).update_attribute :public, false
  end

  def latlon
    [self.lat, self.lon]
  end

  #############################################################################
  # Rendering
  #############################################################################
  
  def url
    "/#{city_name.downcase}"
  end
  
  def url_logo
    self.public ? "/data/#{city.name}/logo.png" : "/images/coming_soon.jpg"
  end

  def station_names_json
    if local_names
      self.stations.map{|s| "#{s.name} (#{s.name_local})"}.to_json
    else
      self.stations.map{|s| "#{s.name}"}.to_json
    end
  end

  def station_ids_json
    self.stations.map(&:id).to_json
  end
  
  def name
    "#{self.city_name}, #{self.country} (#{self.metro_name})"
  end

  def image_path
    "/maps/#{self.city_name}/map.png"
  end

  def system_image_path
    Rails.root.to_s + '/public' + self.image_path
  end

end