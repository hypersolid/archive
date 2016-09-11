class CategoriesController < ApplicationController
  def index
    @categories = Category.by_hits.all.reject(&:empty?)
    @firms = Firm.by_hits.all
  end
  
  def show
    @category = Category.find_by_name(params[:id])
    @category.hit!
    firms = @category.firms.by_hits
    @firms_opened = firms.select(&:opened)
    @firms_closed = firms.select(&:closed)
  end
  
  def tabs
    @category = Category.find(params[:id])
    @firm = Firm.find(params[:firm_id])
    render :layout => nil
  end
  
end
