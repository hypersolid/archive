require_relative "../spec_helper"

describe EmailFallback do

  before(:each) do
    @tournament = Factory(:tournament)
  end

  it "should send correct email and create an instance on #proxy(:invite_by_email, ...) call " do
    user = Factory(:user)
    relation = Factory(:email_relation, :user_id => user.id, :email => "john@gmail.com", :request_id => "REQUEST_ID")

    fallback = EmailFallback.proxy(:invite_by_email, relation, 'hi there')

    fallback.should_not == nil
    last_email.to.should include("john@gmail.com")
    last_email.body.should include(fallback.id.to_s)
    last_email.body.should include("REQUEST_ID")
  end

  # it "should send correct email and create an instance on #proxy(:has_played_email, ...) call " do
  #   invitee = Factory(:user)
  #   inviter = Factory(:admin_user)
  #   relation = Factory(:email_relation, :user_id => inviter.id, :wingman_id => invitee.id, :state => 'active')
  # 
  #   fallback = EmailFallback.proxy(:has_played_email, invitee)
  # 
  #   fallback.should_not == nil
  #   last_email.to.should include(inviter.email)
  #   last_email.body.should include(fallback.id.to_s)
  # end

end