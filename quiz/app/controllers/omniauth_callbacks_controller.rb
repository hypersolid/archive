class OmniauthCallbacksController < Devise::OmniauthCallbacksController

    def facebook
      auth = request.env["omniauth.auth"]
      auth[:extra][:raw_info][:email] = current_user.email if email_signed_in?

      @user = User.find_by_facebook_uid(auth[:uid]) 
      @user ||= User.find_for_facebook_oauth(auth)
      
      relation = Relation.where(:state => "pending", :request_id => session[:request_id]).first if session[:request_id]
      relation ||= Relation.where(:state => "pending", :email => @user.email).first

      if relation && relation.user_id != @user.id
        relation.accept_relation(@user)
        flash[:alert] = "Now you are wingman of #{relation.user.name}" if relation.active?
        session[:request_id] = nil
      end

      session[:auth] = auth

      if @user.facebook_friends.empty?
        mogli_client = Mogli::Client.new(session[:auth][:credentials][:token])
        users = Mogli::User.find("/me/friends", mogli_client)
        @user.update_friends(users.map(&:id))
      end

      if @user.persisted?
        logger.debug I18n.t "devise.omniauth_callbacks.success", :kind => "Facebook"
        flash[:notice] = I18n.t "devise.omniauth_callbacks.success", :kind => "Facebook"

        @user.update_attribute :token, auth[:credentials][:token]

        a = @user.authentications.find_or_create_by_provider_and_uid(auth[:provider], auth[:uid])
        a.update_attribute(:image, auth[:info][:image])
        
        FacebookFriend.update_all({:friend_id => @user.id}, {:facebook_uid => @user.facebook_uid})
        sign_in_and_redirect @user, :event => :authentication
      else
        session["devise.facebook_data"] = auth
        redirect_to ladders_url
      end

    end

  def failure
    redirect_to ladders_url
    flash[:notice] = "Authorization failed"
  end
end