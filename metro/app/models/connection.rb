class Connection < ActiveRecord::Base
  belongs_to :city
  belongs_to :line
  belongs_to :station
  belongs_to :target, :class_name => Station

  def get_color
    if self.color == nil && self.line_id
      self.update_attribute :color, self.line.color
    end
    self.color
  end

  def get_bezier
    unless self.bezier
      s = self.station.get_xy
      t = self.target.get_xy
      result = "M #{s[0]} #{s[1]} "
      if self.line
        cp1 = station.bezier_coords(self.line.id, target)
        cp2 = target.bezier_coords(self.line.id, station)
        result += "C #{cp1[0]} #{cp1[1]} #{cp2[0]} #{cp2[1]} #{t[0]} #{t[1]}"
      else
        result += "L #{t[0]} #{t[1]}"
      end
      self.update_attribute :bezier, result
    end
    self.bezier
  end

  def self.between(src, dst)
    return [] if src.id == dst.id
    Connection.where(['(station_id = ? and target_id = ?) or  (station_id = ? and target_id = ?)', src.id, dst.id, dst.id, src.id]).first
  end
  
  def self.btw(s)
     stations = s.strip.split(' ')
     self.between(Station.find(stations[0]), Station.find(stations[1]))
  end
  
  def self.all_between(src, dst)
    return [] if src.id == dst.id
    Connection.where(['(station_id = ? and target_id = ?) or  (station_id = ? and target_id = ?)', src.id, dst.id, dst.id, src.id]).all
  end

  def get_distance
    unless self.distance
      self.update_attribute :distance, self.station.distance(self.target)
    end
    self.distance
  end
  
  def to_s
    "#{self.station.name} <> #{self.target.name} | #{self.line.name}"
  end
end