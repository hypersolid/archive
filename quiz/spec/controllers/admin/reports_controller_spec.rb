require_relative '../../spec_helper'

describe Admin::ReportsController do
  before(:each) do
    login_admin
  end

  describe "GET index" do
    it "assigns all questions as @questions" do
      @user = Factory(:user, :email => "tom@sawyer.com")
      @quiz = Factory(:quiz, :user => @user)
      @answer = Factory(:answer, :question => Factory(:question))

      get :index
      response.should be_success

      assigns(:answers).size.should eq(5)
      assigns(:games).size.should eq(7)
      assigns(:new_users).size.should eq(7)
    end
  end
end