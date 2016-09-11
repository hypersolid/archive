module LaddersHelper

  def time_left_digits
    time_left = current_tournament.time_left
    if time_left
      time_left.map{|k,v| sprintf("%02d",v)}.join("").last(8)
    else
      "0" * 8
    end
  end

end