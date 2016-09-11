require_relative '../spec_helper'

describe LaddersController do
  describe "with current tournament" do
    before(:each) do
      login_user
      setup_controller_stubs
    end

    it "redirects new users to the quiz page" do
      get :index
      response.should be_redirect
    end

    it "generates ladder page" do
      user = User.first
      quiz = Factory(:quiz, :user => user)
      Factory(:ladder, :user => user, :tournament => Tournament.first)

      get :index
      response.should be_success
      assigns(:ladders).should_not be_empty
    end

    it "generates requested ladder" do
      @ladder = Factory(:ladder, :user => User.first, :tournament => Tournament.first)
      get :show, {:id => 1}
      response.should be_success
    end

    it "revokes invitation by id" do
      @relation = Factory(:email_relation, :user => User.first)
      get :remove_wingman, {:format => :js, :id => @relation.id}
      response.should be_success
      @relation.reload.should be_revoked
    end
    
    it "should send has_played email on invitee's first game when the game is over" do
      invitee = User.first
      inviter = FactoryGirl.create(:admin_user)
      relation = FactoryGirl.create(:email_relation, :user_id => inviter.id, :wingman_id => invitee.id, :state => 'active')
      ladder = Factory(:ladder, :user => invitee, :tournament => Tournament.first)
  
      session[:next_question] = FactoryGirl.create(:question)
      session[:quiz] = FactoryGirl.create(:quiz, :user => invitee, :tournament => Tournament.first)
      session[:start_position] = 20
      session[:start_score] = 0
  
      EmailFallback.should_receive(:proxy)
  
      get :game_over
      response.should be_success
    end
  end

  describe "without the tournament" do
    it "displays empty page" do
      @quiz = Factory(:quiz, :user => User.first, :tournament => nil)
      get :index
      response.body.should include("has not yet started")
    end
  end
end
