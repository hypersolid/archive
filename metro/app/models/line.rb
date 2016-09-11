class Line < ActiveRecord::Base
  belongs_to :city
  has_many :connections
  has_many :lines_stations

  has_and_belongs_to_many :stations

  def drop
    self.connections.destroy_all
    self.lines_stations.destroy_all
  end

  def endpoints
    self.stations.select{|s| Connection.where(['(target_id=? OR station_id=?) AND line_id = ?',s.id, s.id, self.id]).count<2}
  end

  def get_next_connection(connection, station)
    Connection.where(['id!=? AND (target_id=? OR station_id=?) AND line_id = ?',connection.id, station.id, station.id, self.id]).first
  end

  def get_endpoint_station(connection, station)
    points = self.endpoints
    return nil if points.size != 2

    midpoint = nil
    while true
      #puts connection.to_s
      midpoint = (station == connection.station ? connection.target : connection.station)
      return midpoint if points.include?(midpoint)

      connection = self.get_next_connection(connection, midpoint)
      station = midpoint
    end

  end
  
  
  def drop
    #TODO
  end
  
end