class Admin::ReportsController < ApplicationController
  before_filter :require_admin_user
  layout "admin"

  def index
    days_ago = (0..6).to_a
    periods = days_ago.map{|x| x.days.ago.to_date..(x-1).days.ago.to_date}
    days_ago.reverse!
    
    @answers = (1..5).map{|d| [
      d.to_s, 
      Answer.count_with_difficulty(d), 
      Question.with_difficulty(d).count
    ]}

    @games = days_ago.map{|x| [
      x.days.ago.to_date.to_s(:short), 
      Quiz.where(:created_at => periods[x], :paid => false).count, 
      Quiz.where(:created_at => periods[x], :paid => true).count
    ]}

    @new_users = days_ago.map{|x| [
      x.days.ago.to_date.to_s(:short), 
      User.where(:created_at => periods[x]).count
    ]}
  end
end