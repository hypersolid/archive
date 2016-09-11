class PagesController < ApplicationController
  layout "pages"
  
  def index
    render "pages/#{params[:name]}"
  end
end