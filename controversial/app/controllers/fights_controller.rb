class FightsController < ApplicationController
  before_filter :pick_a_fight,:only=>[:show]
  
  def pick_a_fight
    @fight=Fight.find_by_slug(params[:id]) 
    @fight=Fight.find_by_id(params[:id]) if @fight.nil?
    @fight=Fight.all(:order => 'featured DESC, votes DESC', :limit => 1).first if @fight.nil?
    render :text => 'Maintenance mode.' if @fight.nil?  
    
    @brand = @fight.find_brand_by_slug(params[:brand_id]) if params[:brand_id]
  end
  
  def show
    @fights_top=Fight.trend.limit(8) unless fragment_exist?("header")

    @vote=cookies["vote#{@fight.id}".to_sym].to_i
    @other_vote = (@vote==1 ? 2 : 1) if @vote != 0
    unless fragment_exist?("fight#{@fight.id}vote#{@vote}")
      @paths={ 1=>"#{HOST}#{@fight.url}/#{@fight.brand1.url}", 
               2=>"#{HOST}#{@fight.url}/#{@fight.brand2.url}"}
      @fight_prev=@fight.prev
      @fight_next=@fight.next
    end
  end
  
  def index
    render :action => "show"
  end
end