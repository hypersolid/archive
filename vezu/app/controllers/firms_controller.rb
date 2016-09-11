# encoding: utf-8

class FirmsController < ApplicationController

  def show
    @firm = Firm.find_by_name(params[:firm])
    @firm.hit!
    
    @categories = @firm.categories.by_hits
    @category = (Category.find_by_name(params[:category]) or @categories.first)
    @all = true if params[:category]=='всё'
    
    redirect_to '/' unless @category
  end
  
end