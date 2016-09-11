class SitemapController < ApplicationController
  layout nil

  def index
    headers['Content-Type'] = 'application/xml'
    
    @categories = Category.all
    @firms = Firm.all
    @pages = Page.all
    
    respond_to do |format|
      format.xml
    end
  end
  
  def robots
    render :text => open(Rails.root.to_s+'/public/robots.txt').read, :layout => false
  end
end