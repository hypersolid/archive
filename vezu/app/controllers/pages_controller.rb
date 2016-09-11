class PagesController < ApplicationController

  def show
    @page = Page.find_by_slug(params[:slug])
    redirect_to root_url unless @page
  end
  
end
