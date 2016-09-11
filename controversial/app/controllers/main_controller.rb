class MainController < ApplicationController
  before_filter :authenticate_user!, :only=>:admin
  
  def admin
    redirect_to admin_fights_path
  end
end
