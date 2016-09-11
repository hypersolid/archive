class Admin::UsersController < ApplicationController
  before_filter :require_admin_user
  layout "admin"

  def index
    @tournament = Tournament.current
    @users = User.paginate :page => params[:page], :per_page => 20
  end

  def add_credit
    @user = User.find(params[:id])
    @user.increment!(:credits)
  end

  def show
    @user = User.find(params[:id])
  end

  def edit
    @user = User.find(params[:id])
  end

  def create
    @user = User.new(params[:user])

    if @user.save
      redirect_to(admin_user_url(@user), :notice => 'User was successfully created.')
    else
      render :action => "new"
    end
  end

  def update
    @user = User.find(params[:id])
    if @user.update_attributes(params[:user])
      redirect_to(admin_users_url, :notice => 'User was successfully updated.')
    else
      render :action => "edit"
    end
  end

  def destroy
    @user = User.find(params[:id])
    @user.destroy
    Tournament.current.refresh_scores!

    redirect_to(admin_users_url)
  end

  def passes
    @questions = User.find(params[:id]).answers.all(:conditions => {:answer => nil}, :include => :question).map(&:question).compact
  end
end
