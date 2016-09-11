class VotesController < ApplicationController
  def create
    unless params[:vote][:brand_id].blank?
      vote=Vote.new(:brand_id=>params[:vote][:brand_id])
      vote.meta1=request.remote_ip
      vote.save
    end

    unless params[:vote][:total_votes].blank?
      f = Fight.find(params[:fight_id])
      t = params[:vote][:total_votes].to_i
      f.votes = t unless f.votes > t
      f.save
    end

    render :text=>'"ok"'
  end
end