class UsersController < ApplicationController
  layout 'application'
  
  before_filter :authenticate_user!

  def edit
    @user = current_user
  end
  
  def update
    @user = (current_user.admin? && params[:id] ? User.find(params[:id]) : current_user)
    params[:user][:password] = params[:user][:password].blank? ? nil : params[:user][:password]
    params[:user][:password_confirmation] = params[:user][:password].blank? ? nil : params[:user][:password_confirmation]
    params[:user][:status_message].strip! unless params[:user][:status_message].blank?
    success = @user.update_attributes(params[:user])
    unless request.xhr?
      if success
        redirect_to ladders_path, :notice => 'Profile was successfully updated.'
      else
        render 'edit'
      end
    end
  end
  
end