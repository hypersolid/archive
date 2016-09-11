class EmailFallbacksController < ApplicationController

  def show
    @fallback = EmailFallback.find_by_token(params[:id])
    render :text => @fallback.body, :layout => false 
  end

end