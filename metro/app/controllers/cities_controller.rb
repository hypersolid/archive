class CitiesController < ApplicationController
  def index
    @cities = City.all(:order => "nstations DESC")
  end

  def az
    @cities = City.all(:order => :city_name)
    @popular_cities = City.all(:order => "nstations DESC", :limit => 8)
  end

  def show
    @city = City.find_by_city_name(params[:id].split(' ').map(&:capitalize).join(' '))
    @other_cities = City.all(:conditions => ["country = ? and id != ?", @city.country, @city.id])
  end

  def route
    src = Station.find(params[:src_id])
    dst = Station.find(params[:dst_id])
    @route = Route.get(src, dst)
    @route.hit
    @ajax = true
  end
  
end