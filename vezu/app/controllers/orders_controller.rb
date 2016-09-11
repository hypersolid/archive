class OrdersController < ApplicationController

  def make
    p params[:list]
    result = ""
    content = params[:list].each{|k,v| result << "#{v["name"]} #{v["price"]}x#{v["count"]}<br/>"}
    Order.create(:page => params[:page], :content => result, :total => params[:total], :ip => request.remote_ip)
    render :text => 'ok'
  end

end
