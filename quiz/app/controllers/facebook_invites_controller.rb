class FacebookInvitesController < ApplicationController
  # before_filter :set_return_url
  before_filter :authenticate_user!, :except => [:index]

  layout nil

  def create
    conditions = {:tournament_id => current_tournament.id, :state => "pending", :invited_by => "facebook", :wingman_id => nil, :user_id => current_user.id}
    @relation = Relation.create!(conditions.merge(:request_id => Devise.friendly_token[0,30])) if current_user.can_send_invites?
  end

  # FB Canvas action
  def index
    render "discovery" and return if params[:type] == "discovery" || params[:ref] == "ts"

    if params[:code] # need to exchange code for a oauth_token
      authenticator = Mogli::Authenticator.new(FACEBOOK[:app_id], FACEBOOK[:app_secret], request.url.sub(/&code=.*/, ""))
      @mogli_client = Mogli::Client.create_from_code_and_authenticator(params[:code], authenticator)
    end

    begin
      sign_in_from_signed_request unless user_signed_in?
    rescue Mogli::Client::OAuthException
      # Related docs:
      #
      # https://developers.facebook.com/docs/reference/dialogs/oauth/
      # https://developers.facebook.com/docs/authentication/permissions/
      # https://developers.facebook.com/docs/authentication/server-side/

      render "request_permissions" and return
    end

    # show requests' list if 'request_ids' has multiple pending requests
    # or accept a request
    @relations = Relation.where(:state => "pending", :request_id => params[:request_ids].split(",").map{|request_id| "#{request_id}_#{current_user.facebook_uid}"}).all

    if @relations.size == 1
      @relations.first.accept_relation(current_user)

      # delete the request after it has been accepted
      request = Mogli::AppRequest.find(@relations.first.request_id, mogli_client)
      request.destroy if request
    end
  end

  # https://developers.facebook.com/docs/reference/dialogs/requests/
  def create
    @sent, @taken = [], []

    for to_user in params[:to]
      if current_user.can_send_invites?
        fb_user = Mogli::User.find(to_user)

        user = User.find_by_facebook_uid(fb_user.id)
        if user && (user.have_played_quiz? || user.leader)
          @taken << user
        else
          @sent << Relation.create!(
            :invited_by => 'facebook',
            :email => fb_user.email,
            :name => fb_user.first_name + " " + fb_user.last_name,
            :facebook_image_url => fb_user.sized_image_url(:square),
            :user => current_user,
            :request_id => "#{params[:request]}_#{to_user}",
            :tournament => Tournament.current
          )
        end
      end
    end

    # TODO: delete all requests from facebook
    # if user already has 2 pending or active Relations

    @page = params[:page]
    render "email_invites/create"
  end

  private  
  def mogli_client
    unless @mogli_client
      data = FBGraph::Canvas.parse_signed_request(FACEBOOK[:app_secret], params[:signed_request])
      @mogli_client = Mogli::Client.new(data["oauth_token"])
    else
      @mogli_client
    end
  end

  def sign_in_from_signed_request
    # find or create FB user
    fb_user = Mogli::User.find("/me", mogli_client)

    @user = User.find_or_create_by_email(fb_user.email, 
      :facebook_uid => fb_user.id,
      :name => fb_user.name, 
      :gender => fb_user.gender, 
      :password => Devise.friendly_token[0,20]
    )
    sign_in @user
  end
end