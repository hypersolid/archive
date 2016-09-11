require_relative "../spec_helper"

describe Relation do
  before(:each) do
    @tournament = Factory(:tournament)
    @wingman = Factory(:user, :email => "wingman@gmail.com")
    @user = Factory(:user)
    @relation = Factory(:email_relation, :wingman => @wingman, :user => @user, :tournament => @tournament)
  end

  it "creates relation in pending state" do
    @relation.should be_pending
  end

  it "pending relation can be accepted when Tournament is active" do
    @relation.accept!
    @relation.should be_active
  end

  it "pending relation can NOT be accepted when Tournament isn't active" do
    @tournament.update_attribute :ends_at, Date.yesterday
    @tournament.should_not be_active
    expect{
      @relation.accept!
    }.should raise_error(AASM::InvalidTransition)
    @relation.should_not be_active
  end

  it "pending relation can be revoked" do
    @relation.revoke!
    @relation.should be_revoked
  end

  it "new pending relation adds 2 credits" do
    expect {
      Factory(:email_relation, :user => @user, :tournament => @tournament, :request_id => Devise.friendly_token[0,30])
    }.to change(@user, :credits).by(2)
  end
  
  it "new pending relation does not add credits if user already has 2 relations" do
    Factory(:email_relation, :user => @user, :tournament => @tournament, :state => "revoked", :request_id => Devise.friendly_token[0,30])
    expect {
      Factory(:email_relation, :user => @user, :tournament => @tournament)
    }.to change(@user, :credits).by(0)
  end

  it "revoked relation can be revoked" do
    @relation.revoke!
    @relation.revoke!
    @relation.should be_revoked
  end

  it "accepts relation for a given user" do
    @relation.accept_relation(@wingman)

    @relation.should be_active
    @relation.wingman.should == @wingman
    @user.reload.credits.should == 2
  end

  it "should send notification of wingman request acceptance" do
    @relation.accept_relation(@wingman)

    last_email.to.should include(@relation.user.email)
    last_email.body.should include(@wingman.name)
  end

  it "should NOT send notification of wingman request acceptance to user which turned it off" do
    @relation.user.update_attribute :email_wingman_request_accepted, false
    EmailFallback.should_not_receive :proxy

    @relation.accept_relation(@wingman)
  end

  it "revokes relation when it cannot be accepted" do
    @relation.stub(:can_be_accepted?).and_return(false)
    @relation.accept_relation(@wingman)
    @relation.should be_revoked
  end

  it "allows user to have an unlimited number of revoked Relations" do
    @user = @relation.user

    10.times do
      @relation = Factory(:email_relation, :user => @user, :state => "revoked")
    end

    @user.relations.count.should == 11
  end

  it "allows user to have a maximum of 2 active relations in active tournament" do
    @user = @relation.user

    3.times do |i|
      @relation = Factory(:email_relation, :user => @user, :state => "pending") 
      @relation.accept_relation(Factory(:user, :email => "user#{i}@example.com")) rescue nil
    end

    @user.relations.where(:state => "active").count.should == 2
  end

  it "revokes active relation if user haven't played a quiz" do
    @relation.accept_relation(@wingman)
    @relation.should be_active
    @relation.revoke!
    @relation.should be_revoked
  end

  it "restricts revoke of active relation if users have played a quiz" do
    @relation.accept_relation(@wingman)
    @relation.should be_active

    @quiz = Factory(:quiz, :user => @wingman, :tournament => @tournament)
    expect{
      @relation.revoke!
    }.should raise_error(AASM::InvalidTransition)
  end

  it "finds, creates, revokes pending Facebook relations" do
    @r1 = Relation.find_or_create_pending_fb_relation(@user.id)
    @r2 = Relation.find_or_create_pending_fb_relation(@user.id)
    @r2.should == @r1
    @r2.revoke!
    @r2.should be_revoked

    @r3 = Relation.find_or_create_pending_fb_relation(@user.id)
    @r4 = Relation.find_or_create_pending_fb_relation(@user.id)
    @r4.should == @r3
    @r4.accept_relation(Factory(:user, :email => "wingman@example.com"))
    @r4.should be_active

    # @r5 = Relation.find_or_create_pending_fb_relation(@user.id)
    # @r5.should be_pending
  end
end