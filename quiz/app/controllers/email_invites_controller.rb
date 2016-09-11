class EmailInvitesController < ApplicationController
  before_filter :authenticate_user!, :only => [:create]
  layout nil

  # POST /email_invites/create(.:format)
  def create
    @sent, @taken = [], []
    emails = []

    emails << [params[:email1], (params[:name1] == 'Name' ? nil : params[:name1])] if validate_email(params[:email1])
    emails << [params[:email2], (params[:name2] == 'Name' ? nil : params[:name2])] if validate_email(params[:email2])

    emails.each do |email,name|
      if current_user.can_send_invites?
          user = User.find_by_email(email)
          if user && (user.have_played_quiz? || user.leader) 
            @taken << user
          else
            @sent << Relation.create!(
              :invited_by => 'email',
              :email => email,
              :name => name,
              :user => current_user,
              :request_id => Devise.friendly_token[0,30],
              :tournament => Tournament.current
            )
            EmailFallback.delay.proxy(:invite_by_email, @sent.last, params[:message])
          end
      end
    end

    # @page = params[:page]
  end

end