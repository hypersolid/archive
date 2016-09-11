require_relative '../spec_helper'

describe EmailInvitesController do
  before(:each) do
    login_user
    setup_controller_stubs
  end

  it "should have a current_user" do
    subject.current_user.should_not be_nil
  end

  it "creates relations into DB and sends invitation by email" do
    message = "Hi, let's play together!"
    expect {
      post :create, {
        :format => :js, :message => message,
        :email1 => 'john@example.com', :name1 => 'John', 
        :email2 => 'james@example.com', :name2 => 'James'
      }
    }.to change(Relation, :count).by(2)
    response.should be_success

    Delayed::Worker.new.work_off

    last_email.to.should include("james@example.com")
    last_email.body.should include(Relation.last.request_id)
    last_email.body.should include(message)
  end

end