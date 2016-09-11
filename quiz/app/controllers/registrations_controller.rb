class RegistrationsController < Devise::RegistrationsController
  def create
    # @user = User.create(params[:user])
    # if @user.save
    #   sign_in @user
    #   accept_relation(@user) if session[:request_id]
    # end
    redirect_to ladders_url
  end
end