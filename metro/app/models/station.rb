class Station < ActiveRecord::Base
  attr_accessor :v_d # distance
  attr_accessor :v_p # previous station
  attr_accessor :v_l # current line

  belongs_to :city

  has_one :nearest, :class_name => 'Station', :foreign_key => 'nearest_id'

  has_and_belongs_to_many :lines

  has_many :connections, :dependent => :destroy
  has_many :targets, :class_name => 'Connection', :foreign_key => 'target_id', :dependent => :destroy

#############################################################################
# Static methods
#############################################################################

  def self.haversine_distance(lat1, lon1, lat2, lon2)
    rpd = Math::PI / 180
    rm = 6371000

    dlon = lon2 - lon1
    dlat = lat2 - lat1
    dlon_rad = dlon * rpd
    dlat_rad = dlat * rpd
    lat1_rad = lat1 * rpd
    lon1_rad = lon1 * rpd
    lat2_rad = lat2 * rpd
    lon2_rad = lon2 * rpd

    a = Math.sin(dlat_rad/2)**2 + Math.cos(lat1_rad) * Math.cos(lat2_rad) * Math.sin(dlon_rad/2)**2
    c = 2 * Math.asin( Math.sqrt(a))
    return rm * c
  end

  def self.connect(source, target, line = nil)
    Connection.create(:station => source, :target => target, :line=>line, :city => source.city) rescue nil
  end

  def self.sum_vectors(v1, v2)
    x = v1[0] * Math.cos(v1[1]) + v2[0] * Math.cos(v2[1])
    y = v1[0] * Math.sin(v1[1]) + v2[0] * Math.sin(v2[1])

    a = (x > 0 ? Math.atan(y/x) : Math.atan(y/x) + Math::PI)
    r = Math.sqrt(x**2 + y**2)
    [r, a]
  end
  

#############################################################################
# Essential methods
#############################################################################

  def mercator
    p = Math::PI
    to_rad = 1/180.0 * Math::PI
    r =  6371000 * 1e-1
    
    lambda = (self.lon - self.city.lon) * to_rad 
    station_phi = self.lat * to_rad
    city_phi = self.city.lat * to_rad
       
    x = lambda
    y = Math.log(p/4 + Math.tan(station_phi)/2) - Math.log(p/4 + Math.tan(city_phi)/2)
    
    [r * x, - r * y]
  end


  def neighbors(line_id = nil)
    cs = Connection.where(['(station_id = ? OR target_id = ?)', self.id, self.id])
    cs = cs.where('line_id = ?', line_id) if line_id

    ns = []
    cs.all.each do |c|
      ns << c.station_id if c.station_id != self.id
      ns << c.target_id if c.target_id != self.id
    end
    ns.uniq
  end

  def angle(another)
    dx=self.get_xy[0] -  another.get_xy[0]
    dy=self.get_xy[1] -  another.get_xy[1]
    a = Math.atan2(dx,-dy)+Math::PI/2
    a = a % (Math::PI * 2)
    a < 0 ? a + Mathcircle::PI * 2 : a
  end

  def bezier(line_id)
    magnitude = 4
    threshold = 2

    ns = self.neighbors(line_id).map{|n| Station.find(n)}
    if ns.size == 1
      a = self.angle(ns[0])
      r = Math.log(self.distance(ns[0])) * 0
    else
      a1 = self.angle(ns[0])
      a2 = self.angle(ns[1])
      r1 = Math.log(self.distance(ns[0]))
      r2 = Math.log(self.distance(ns[1]))

      x = r1 * Math.cos(a1) + r2 * Math.cos(a2)
      y = r1 * Math.sin(a1) + r2 * Math.sin(a2)

      a = (x > 0 ? Math.atan(y/x) : Math.atan(y/x) + Math::PI)  + Math::PI
      r = Math.sqrt(x**2 + y**2)
    end
    r = 0 if r < threshold / magnitude
    [r * magnitude, a % (Math::PI * 2)]
  end


  def text_coords
    unless self.tx && self.ty
      r = 0
      l = self.width
      h = self.height
      p = Math::PI

      a = 0
      unless self.text_bias
        line_id = (self.connections + self.targets).map(&:line_id).compact.first
        if line_id
          a = self.bezier(line_id)[1]
          a += p if self.endpoint(line_id)
        end 
      else
        a = self.text_bias
      end

      rcx = self.get_xy[0]
      rcy = self.get_xy[1]
      rcx += r * Math.cos(a)
      rcy += r * Math.sin(a)

      a %= 2 * p
            
      if self.name
        # find critical angles
        ca1 = Math.atan(Float(h)/l)
        ca2 = p - ca1
        ca3 = p + ca1
        ca4 = 2 * p - ca1
        
        # consider cases of vertical & horizontal shifts    
        unless (a > ca1 && a < ca2) || (a > ca3 && a < ca4)
          sgn = Math.cos(a) / Math.cos(a).abs
          rcx += l/2 * sgn 
          rcy += l/2 * Math.tan(a)
        else
          sgn = Math.sin(a) / Math.sin(a).abs
          rcx += h/2 / Math.tan(a)
          rcy += h/2 * sgn 
        end
        rcx -= l/2 
      end
      self.update_attributes({:tx=>rcx, :ty=>rcy})
    end
    [self.tx, self.ty]
    #[rcx,rcy]
  end

  def bezier_coords(line_id, station = nil)
    a = self.angle(station)
    b = self.bezier(line_id)[1]

    if station
      d = a - b
      b += Math::PI/2 if  d > 0 && d < Math::PI || d < 0 && d < - Math::PI
      b -= Math::PI/2 if  d < 0 && d > - Math::PI || d > 0 && d > Math::PI
    end

    r = self.bezier(line_id)[0]
    [self.get_xy[0] + r * Math.cos(b),self.get_xy[1] + r * Math.sin(b)]
  end

#############################################################################
# Getters
#############################################################################

  def get_transit
    if self.transit == nil
      self.update_attribute :transit, Connection.exists?(['(station_id = ? or target_id =?) and line_id is null',self.id,self.id]) || self.lines.count > 1
    end
    self.transit
  end

  def get_color
    if self.color == nil
      self.update_attribute :color, (lines.empty? ? 'black' : self.lines.last.color)
    end
    self.color
  end

  def get_xy
    unless self.x && self.y
      scale =  (self.city.scale ? self.city.scale : 1)

      xy = self.mercator

      self.update_attributes({:x => xy[0] * scale ,:y => xy[1] * scale})
    end
    [self.x, self.y]
  end

#############################################################################
# Helpers
#############################################################################

  def inner_width
    return 100 if self.name.blank?
    #self.name.size * 8
    the_text = self.name
    label = Magick::Draw.new
    label.font = "Arial, Helvetica, sans-serif"
    label.text_antialias(true)
    label.font_style=Magick::NormalStyle
    label.font_weight=Magick::BoldWeight
    label.gravity=Magick::CenterGravity
    label.pointsize = 10
    label.text(0,0,the_text)
    metrics = label.get_type_metrics(the_text)
    metrics.width
  end
  
  def width
    self.inner_width + 12
  end

  def height
    h = 34
    h /= 1.8 unless self.city.local_names 
    h
  end

  def distance(another)
    return 0 if self.id == another.id
    Station.haversine_distance(self.lat, self.lon, another.lat, another.lon)
  end

  def get_nearest
    unless self.nearest
      stations = Station.all(:conditions=>["city_id = ? and id != ?", self.city_id, self.id])
      unless stations.empty?
        stations.sort!{|s1,s2| s1.distance(self) <=> s2.distance(self)}
        self.update_attribute :nearest, stations.first
      end
    end
    self.nearest
  end

  def distance_nearest
    self.distance(self.get_nearest)
  end  

  def endpoint(line_id)
    self.neighbors(line_id).count == 1
  end
  
#############################################################################
# Maintenance
#############################################################################

  def drop
    self.connections.destroy_all
    self.targets.destroy_all
    self.lines = []
    self.save
  end

#############################################################################
# Rendering
#############################################################################

  def tip
    "#{self.name} / #{self.name_local} station | #{self.lines.map(&:name).join(',')} lines"
  end

  def html_link
    "<a class='hs' href='#' data-coords='#{self.get_xy.join(',')}' title='Show #{self.name} station on the map'>#{self.name}</a>"
  end

end