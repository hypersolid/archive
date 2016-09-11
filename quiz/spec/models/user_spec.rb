require_relative "../spec_helper"

describe User do
  before(:each) do
    @user = Factory(:user)
    @tournament = Factory(:tournament)
  end

  it "detects new users having no quizzes" do
    @user.new_user?.should be_true
  end

  it "detects existing users" do
    @user.update_attribute :created_at, 1.week.ago
    @user.new_user?.should be_false
  end

  it "detects existing users who need credits for tournament" do
    @user.update_attribute :created_at, 1.week.ago
    @user.existing_user_needs_credits?.should be_true
  end

  it "detects existing users who don't need credits for tournament" do
    @user.update_attribute :created_at, 1.week.ago
    @quiz = Factory(:quiz, :user => @user, :tournament => @tournament)
    @user.existing_user_needs_credits?.should be_false
  end

  it "cleans up relations on destroy" do
    @wingman1 = Factory(:user, :email => "wingman1@gmail.com")
    @wingman2 = Factory(:user, :email => "wingman2@gmail.com")

    @relation1 = Factory(:email_relation, :wingman => @wingman1, :user => @user, :state => "active")
    @relation2 = Factory(:facebook_relation, :wingman => @wingman2, :user => @user, :state => "active")    
    @user.wingmen.count.should == 2

    @wingman2.destroy
    @user.wingmen.count.should == 1

    @user.destroy
    Relation.where(:id => [@relation1, @relation2]).count.should == 0
  end

  it "counts admin as not paying" do
    @admin_user = Factory(:admin_user)
    @admin_user.pays?.should be_false
  end

  it "counts payment flag for new users" do
    @user.pays?.should be_false
    3.times {@user.quizzes.create!}
    @user.pays?.should be_true  
  end

  it "counts payment flag for existing users" do
    @user.update_attribute :created_at, 7.days.ago
    @user.pays?.should be_false
    5.times {@user.quizzes.create!}
    @user.pays?.should be_true  
  end

  it "posts wall message to FB" do
    FBGraph::Client.any_instance.stub_chain("selection.me.feed.publish!").and_return(true)

    @ladder = Factory(:ladder, :user => @user)

    # first call
    @user.post_fb_feed(@ladder).should_not be_nil
    @user.last_fb_post_at.should_not be_nil

    # second call
    @user.post_fb_feed(@ladder).should be_nil
  end
end