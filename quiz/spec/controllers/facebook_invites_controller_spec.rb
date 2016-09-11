require_relative '../spec_helper'
=begin
describe FacebookInvitesController do
  before(:each) do
    setup_controller_stubs
  end

  it "creates new pending FB relation" do
    login_user
    post :create, :format => "js"
    assigns(:relation).state.should == "pending"
  end

  it "accepts relation by request id" do
    @relation = Factory(:facebook_relation, :user => Factory(:user))

    # mock calls to FB API
    mogli_request = mock "MogliRequest"
    Mogli::AppRequest.should_receive(:find).with("164937970272831_100002993348446", instance_of(Mogli::Client)).and_return(mogli_request)
    mogli_request.should_receive(:destroy)

    attrs = FactoryGirl.attributes_for(:user)
    fb_user = mock("MogliUser", :id => 100002993348446, :email => "vfomichov@odesk.com", :name => attrs[:name], :gender => attrs[:gender])
    Mogli::User.should_receive(:find).and_return(fb_user)

    get :index, {"signed_request" => "0tcogabiF4wVEmaSfNLeo8oQilTXVaXb13VFyLwpwgE.eyJhbGdvcml0aG0iOiJITUFDLVNIQTI1NiIsImV4cGlyZXMiOjEzMjQ2ODEyMDAsImlzc3VlZF9hdCI6MTMyNDY3NDA0NCwib2F1dGhfdG9rZW4iOiJBQUFCd1Nqams3WThCQU9NN2s5dVpCWkJGNFdYQzhkRGRLaDRaQU9SMzJvYXlGZjd6M3F2WkNUN3dYU3lhdU44SjlLQzlYOUJQVHJDbVRaQWdINkpWM2wyYVZMRm8xMFR2VE9TWkFHeVJ5YkpKdTVlRGgzek14aSIsInVzZXIiOnsiY291bnRyeSI6InJ1IiwibG9jYWxlIjoicnVfUlUiLCJhZ2UiOnsibWluIjoyMX19LCJ1c2VyX2lkIjoiMTAwMDAyOTkzMzQ4NDQ2In0",
     "request_ids" => "164937970272831",
     "ref" => "notif",
     "app_request_type" => "user_to_user",
     "notif_t" => "app_request"}

    response.should render_template("index")
    assigns(:relations).first.should be_active
    assigns(:user).should == @relation.reload.wingman
    User.count.should == 2
  end

  # it "shows accept page in FB canvas for multiple requests" do
  #   login_user
  #   User.any_instance.stub(:facebook_uid).and_return(100002993348446)
  # 
  #   @relation1 = Factory(:facebook_relation, :user => User.first)
  #   @relation2 = Factory(:facebook_relation, :user => User.first, :request_id => "664937970272831_100002993348446")
  #   
  #   get :index, {"signed_request" => "0tcogabiF4wVEmaSfNLeo8oQilTXVaXb13VFyLwpwgE.eyJhbGdvcml0aG0iOiJITUFDLVNIQTI1NiIsImV4cGlyZXMiOjEzMjQ2ODEyMDAsImlzc3VlZF9hdCI6MTMyNDY3NDA0NCwib2F1dGhfdG9rZW4iOiJBQUFCd1Nqams3WThCQU9NN2s5dVpCWkJGNFdYQzhkRGRLaDRaQU9SMzJvYXlGZjd6M3F2WkNUN3dYU3lhdU44SjlLQzlYOUJQVHJDbVRaQWdINkpWM2wyYVZMRm8xMFR2VE9TWkFHeVJ5YkpKdTVlRGgzek14aSIsInVzZXIiOnsiY291bnRyeSI6InJ1IiwibG9jYWxlIjoicnVfUlUiLCJhZ2UiOnsibWluIjoyMX19LCJ1c2VyX2lkIjoiMTAwMDAyOTkzMzQ4NDQ2In0",
  #    "request_ids" => "164937970272831,664937970272831",
  #    "ref" => "notif",
  #    "app_request_type" => "user_to_user",
  #    "notif_t" => "app_request"}
  # 
  #   response.should render_template("index")
  #   assigns(:relations).size.should == 2
  # end

  it "displays app discovery page" do
    get :index, {
      "signed_request"=>  "pFvv2x5GwkwSu1zoXiAc4qpCWz6kfLT-FmCjqiMs1go.eyJhbGdvcml0aG0iOiJITUFDLVNIQTI1NiIsImlzc3VlZF9hdCI6MTMzMDA3ODY4OCwidXNlciI6eyJjb3VudHJ5IjoicnUiLCJsb2NhbGUiOiJydV9SVSIsImFnZSI6eyJtaW4iOjAsIm1heCI6MTJ9fX0",
       "type"=>"discovery"}

    response.should render_template("discovery")
  end

  it "displays top search page" do
    get :index, {
      "signed_request"=> "a6uSEZSVqGbxYIn7DaAEp58WeSf3rp5P48POF9lgLWE.eyJhbGdvcml0aG0iOiJITUFDLVNIQTI1NiIsImlzc3VlZF9hdCI6MTMzMTg0NDQ2MSwidXNlciI6eyJjb3VudHJ5IjoiY3kiLCJsb2NhbGUiOiJlbl9HQiIsImFnZSI6eyJtaW4iOjE4LCJtYXgiOjIwfX19",
     "ref"=>"ts"}

    response.should render_template("discovery")
  end

  it "requests app permissions" do
    get :index, {
      "signed_request" =>"9l3006UrmleJoA1NFD9KE1s3YjjgUlXbqqOmlvzddRw.eyJhbGdvcml0aG0iOiJITUFDLVNIQTI1NiIsImlzc3VlZF9hdCI6MTMzMjM2MTYxMCwidXNlciI6eyJjb3VudHJ5IjoicnUiLCJsb2NhbGUiOiJydV9SVSIsImFnZSI6eyJtaW4iOjIxfX19", 
      "fb_source"=>"notification", 
      "request_ids"=>"209752602457926", 
      "ref"=>"notif", 
      "app_request_type"=> "user_to_user", 
      "notif_t"=>"app_request"
    }

    response.should render_template("request_permissions")
  end
  
  it "process notifications after permissions grant" do
    @relation = Factory(:facebook_relation, :user => Factory(:user))

    code = "AQBua63KIjyeMzSTc5Hs_mtg-6icZxRxhBQAGMbJUUS4Q21n8hoUf4QAhSFfCB8X7whS8FhLk_IlsL2fYI544XUGYOw3psCJi1LD4tQH1v7bKGVa1E6UO2yXkFIUoNffDbSbDczOwA-_ZN9akery6mHm2Cb7YSOa2eZh_MOKJPRIBqiw4-3YZGKm7VGOZiwOjmmwPHTelRie9dRkGC0kAv8j"

    # mock calls to FB API
    mogli_client = mock "MogliClient"
    Mogli::Client.should_receive(:create_from_code_and_authenticator).with(code, instance_of(Mogli::Authenticator)).and_return(mogli_client)

    mogli_request = mock "MogliRequest"
    Mogli::AppRequest.should_receive(:find).with("164937970272831_100002993348446", mogli_client).and_return(mogli_request)
    mogli_request.should_receive(:destroy)

    attrs = FactoryGirl.attributes_for(:user)
    fb_user = mock("MogliUser", :id => 100002993348446, :email => "vfomichov@odesk.com", :name => attrs[:name], :gender => attrs[:gender])
    Mogli::User.should_receive(:find).and_return(fb_user)

    get :index, {
      "fb_source" => "notification",
      "request_ids" => "164937970272831",
      "app_request_type" => "user_to_user",
      "notif_t" => "app_request",
      "code" => code
    }

    response.should render_template("index")
    @relation.reload.should be_active
  end

end
=end