class Route < ActiveRecord::Base
  belongs_to :city
  belongs_to :source, :class_name => 'Station'
  belongs_to :destination, :class_name => 'Station'

  def self.dijkstra(src, dst)
    # Get all stations and assign distance for all except first
    q = src.city.stations.all
    q.each {|s| s.v_d = (s.id==src.id ? 0 : 1e12)}

    while !q.empty? do
      # Sort an array of unvisited nodes in place and get closest
      u = q.sort!{|a,b| a.v_d <=> b.v_d}.first
      # Break if destination is reached or is unreachable
      dst.v_p = u.v_p; break if u.id == dst.id
      break if u.v_d == 1e12
      # Remove current node from unvisited set
      q.delete(u)

      # Get current node neighbors that are in unvisited set
      neighbors = u.neighbors
      ns = q.select{|s| neighbors.include?(s.id)}

      #puts "Currently at #{u.name}"
      #puts "Neighbors: #{ns.map(&:name).join(",")}"

      ns.each do |v|
        # Calculate distance between current station and all it's unvisited neighbors
        alt = u.v_d + u.distance(v)
        # We need to add extra distance if line was changed
        line_ids = Connection.all_between(u, v).map(&:line_id)
        alt += 1000 unless line_ids.include?(u.v_l)
        #puts "Distance to #{v.name} = #{alt}"
        # If newly calculated distance is lesser than previous - update it
        if alt < v.v_d
          v.v_d = alt
          v.v_p = u
          v.v_l = (line_ids.include?(u.v_l) ? u.v_l : line_ids.first)
        end
      end
    end
    
    route = []
    while u.v_p
      route<<u
      u = u.v_p
    end

    nodes = ([src] + route.reverse)
    edges = []
    nodes.each do |n|
      edges << Connection.all_between(n, n.v_p).select{|c| c.line_id == n.v_l}.first if n.v_p
    end

    unless edges.empty?
      route = Route.create({:nodes => nodes.map(&:id).join(','), :edges => edges.map(&:id).join(','), :city_id => src.city_id, :source => src, :destination => dst})
      route.postprocess
      route
    end
  end

  def self.get(src, dst)
    Route.where(:source_id => src.id, :destination_id => dst.id).first or Route.dijkstra(src, dst)
  end
  
  def self.get_by_ids(src_id, dst_id)
    Route.where(:source_id => src_id, :destination_id => dst_id).first or Route.dijkstra(Station.find(src_id), Station.find(dst_id))
  end

  def get_nodes
    ss = Station.where("id in (#{self.nodes})").all
    ns = self.nodes.split(',').map{|n| Integer(n)}
    
    result = []
    ns.each do |n|
      ss.each do |s|
        result << s if s.id == n
      end
    end
    result
  end

  def get_edges
    cs = Connection.where("id in (#{self.edges})").all
    es = self.edges.split(',').map{|n| Integer(n)}
    
    result = []
    es.each do |e|
      cs.each do |c|
        result << c if c.id == e
      end
    end
    result
  end

  def time
    minutes = (self.distance / 575).round
    hours = minutes / 60
    hours > 0 ? "#{hours} h #{minutes % 60} min" : "#{minutes} min"
  end

  def postprocess
    ns = self.get_nodes
    es = self.get_edges

    switch_lines = 1000
    # calculate distance
    distance = 0
    prev_line_id = nil
    es.each do |e|
      if !e.line_id || (prev_line_id && prev_line_id != e.line_id)
      distance += switch_lines
      else
      distance += e.get_distance
      end
      prev_line_id = e.line_id
    end

    self.update_attribute :distance, distance

    # generate html

    html = []
    through = []
    prev_line = nil
    current_station = ns.first
    es.each do |e|
      next_station = (e.station == current_station ? e.target : e.station)
      puts "Station: #{current_station.name}, Next: #{next_station.name}"
      puts "Current line: #{e.line ? e.line.name : 'nil'}, Previous line: #{prev_line ? prev_line.name : 'nil'}"

      if e.line && (!prev_line || e.line != prev_line)
        html << "Go through #{through.join(', ')} (#{through.size}&nbsp;stations)" unless through.empty?
        through = []
        endpoint = e.line.get_endpoint_station(e, current_station)
        html << "Take <span class='hl' style='background-color:#{e.line.color}'>&nbsp;</span> <b>#{e.line.name} line</b>  at <b>#{current_station.html_link}</b> station #{endpoint ? "to <i>#{endpoint.name}</i> direction" : ''}"
      end
      through << "<i>#{current_station.html_link}</i>" if e.line && e.line == prev_line
      if !e.line
        html << "Go through #{through.join(', ')} (#{through.size}&nbsp;stations)" unless through.empty?
        through = []
        html << "Leave at <b>#{current_station.html_link}</b> (transfer station)"
      end
      if next_station == ns.last
        html << "Go through #{through.join(', ')} (#{through.size}&nbsp;stations)" unless through.empty?
        through = []
        html << "Exit at <b>#{next_station.html_link}</b>"
      end

      current_station = next_station
      prev_line = e.line if e.line
    end

    html << ["<div class='fr'>SubwayMetro.com wishes you a pleasant trip!</div>"]

    self.update_attribute :html, html.join('<br />')

    self.html
  end

  def hit
    self.update_attribute :hits, self.hits + 1
  end

  def url
    "#{self.city.url}/#{self.source.name.downcase}/#{self.destination.name.downcase}"
  end

  def self.deploy(city)
    c = City.find_by_city_name(city)
    counter = 0
    errors = []
    c.stations.each do |s1|
      c.stations.each do |s2|
        if s1 != s2
          puts "#{s1.id} #{s1.name} - #{s2.id} #{s2.name}"
          errors << "#{s1.id} #{s1.name} - #{s2.id} #{s2.name}" unless Route.get_by_ids(s1.id,s2.id)
          puts counter if counter % 1000 == 0
          counter += 1
        end
      end
    end
    errors
  end
end