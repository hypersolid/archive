require_relative '../spec_helper'

describe QuizzesController do
  before(:each) do
    login_user
    setup_controller_stubs
  end

  it "new user get credits" do
    User.any_instance.should_receive(:update_attribute).with(:credits, 3)
    get :new
    response.should be_redirect
  end

  it "when tournament starts, existing users get credits" do
    @user = User.first
    @user.update_attribute :created_at, 1.week.ago
    old_tournament = Factory(:tournament, :starts_at => 10.days.ago, :ends_at => Date.yesterday)
    old_quiz = Factory(:quiz, :user => @user, :tournament => old_tournament)

    @user.existing_user_needs_credits?.should be_true

    User.any_instance.should_receive(:increment!).with(:credits, 5)
    get :new
    response.should be_redirect
  end

  it "users get credits only once" do
    User.any_instance.should_receive(:new_user?).and_return(false)    
    User.any_instance.should_receive(:existing_user_needs_credits?).and_return(false)
    User.any_instance.should_not_receive(:update_attribute)
    get :new
    assigns(:quiz).should be_nil
    response.should be_redirect
  end

  it "charges credits from users" do
    User.any_instance.should_receive(:decrement!).with(:credits)
    get :new
    response.should be_redirect
  end

  it "does not charges admin users" do
    @admin_user = FactoryGirl.create(:admin_user)
    sign_in @admin_user
    @admin_user.stub(:admin?).and_return(true)
    @admin_user.should_not_receive(:decrement!).with(:credits)
    
    get :new
    response.should be_redirect
  end
end
