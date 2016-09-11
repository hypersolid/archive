class Admin::TournamentsController < ApplicationController
  before_filter :require_admin_user
  layout "admin"

  def index
    redirect_to "/admin/tournaments" and return if request.path == "/admin"

    @tournaments = Tournament.all
  end

  def show
    @tournament = Tournament.find(params[:id])
  end

  def new
    @tournament = Tournament.new(:ends_at => 7.days.from_now, :time_limit => 30, :best_time_bonus => 500, :avg_time_bonus => 250, :points_per_second => 100)
    @tournament.tournament_counters.build([
      {:counter => 5, :difficulty => 1},
      {:counter => 4, :difficulty => 2},
      {:counter => 3, :difficulty => 3},
      {:counter => 2, :difficulty => 4},
      {:counter => 0, :difficulty => 5}
    ])
  end

  def edit
    @tournament = Tournament.find(params[:id])
  end

  def create
    @tournament = Tournament.new(params[:tournament])

    if @tournament.save
      redirect_to(admin_tournaments_url, :notice => 'Tournament was successfully created.')
    else
      render :action => "new"
    end
  end

  def update
    @tournament = Tournament.find(params[:id])

    if @tournament.update_attributes(params[:tournament])
      @tournament.refresh_scores!
      redirect_to(admin_tournament_url(@tournament), :notice => 'Tournament was successfully updated.')
    else
      render :action => "edit"
    end
  end

  def destroy
    @tournament = Tournament.find(params[:id])
    @tournament.destroy

    redirect_to(admin_tournaments_url)
  end
end
