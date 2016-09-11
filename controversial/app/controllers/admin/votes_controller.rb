class Admin::VotesController < AdminController
  def index
    @votes = Vote.all(:order=>'created_at DESC',:conditions=>['created_at BETWEEN ? AND ?',Time.now-24.hours, Time.now])
  end
end
