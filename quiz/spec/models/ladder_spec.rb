require_relative "../spec_helper"

describe Ladder do

  before(:each) do
    @user = Factory(:user)
    @quiz = Factory(:quiz, :user => @user)
    @ladder = Factory(:ladder, :user => @user, :tournament => @quiz.tournament, :score => 2)
  end

  it 'should send notifications when user moves up the ladder because of his wingman' do
    good_guy = Factory(:user, :email => 'good_guy@example.com')
    good_guy_ladder = Factory(:ladder, :user => good_guy, :tournament => @quiz.tournament, :score => 0)
    bad_guy = Factory(:user, :email => 'bad_guy@example.com')
    bad_guy_ladder = Factory(:ladder, :user => bad_guy, :tournament => @quiz.tournament, :score => 12)

    wingman = Factory(:user, :email => 'wingman@example.com', :name => 'Awesome Friend')
    Factory(:email_relation, :wingman_id => wingman.id, :user_id => @user.id, :state => "active")
    wingman_ladder = Factory(:ladder, :user => wingman, :tournament => @quiz.tournament, :score => 0)

    @quiz.tournament.refresh_scores!
    @user.ladder.update_attribute :score, 11

    Delayed::Job.delete_all
    wingman_ladder.update_attribute :score, 11
    Delayed::Job.count.should == 2

    Delayed::Worker.new.work_off
    # ActionMailer::Base.deliveries[-3,3].map{|email| email.to.first}.should == [@user.email, bad_guy.email, good_guy.email] 
    ActionMailer::Base.deliveries.last.subject.should include('up 1')
    # ActionMailer::Base.deliveries[-2].subject.should include('down 1')
    # ActionMailer::Base.deliveries[-1].subject.should include('down 1')
  end

  it 'should send notifications when your Facebook friend overtakes you' do
    prize1 = Factory(:prize, :tournament => @quiz.tournament)
    prize2 = Factory(:prize, :position => 2, :amount => 77.77, :tournament => @quiz.tournament)
    good_guy = Factory(:user, :email => 'good_guy@example.com')
    good_guy_ladder = Factory(:ladder, :user => good_guy, :tournament => @quiz.tournament, :score => 3)
    bad_guy = Factory(:user, :email => 'bad_guy@example.com')
    bad_guy_ladder = Factory(:ladder, :user => bad_guy, :tournament => @quiz.tournament, :score => 1)
    @quiz.tournament.refresh_scores!

    FacebookFriend.create!(:facebook_uid => 1206903360, :friend_id => bad_guy.id, :user_id => good_guy.id)
    bad_guy_ladder.reload.update_attribute :score, 4
    Delayed::Worker.new.work_off
    ActionMailer::Base.deliveries.last.subject.should include('overtaken')
  end

  # it 'should send notifications when user moves down the ladder' do
  #   n = 12
  #   n.times do |i|
  #     Factory(:ladder, :user => Factory(:user, :email => "user#{i}@example.com"), :tournament => @quiz.tournament, :score => (n - i) * 10)
  #   end
  # 
  #   @quiz.tournament.refresh_scores!
  #   @ladder.reload.position.should == 13
  #   Delayed::Job.delete_all
  #   @ladder.update_attribute :score, 1000
  #   @ladder.reload.position.should == 1
  #   Delayed::Job.count.should == 12
  # 
  #   Delayed::Worker.new.work_off
  #   ActionMailer::Base.deliveries[-12,12].each do |email|
  #     email.subject.should include('down 1')
  #   end
  # end

  it 'should update up/down flags properly' do
    l1 = Factory(:ladder, :score => 1, :position => 3, :user => Factory(:user, :email => 'l1@ex.ex'), :tournament => @quiz.tournament)
    l2 = Factory(:ladder, :score => 3,  :position => 1, :user => Factory(:user, :email => 'l2@ex.ex'), :tournament => @quiz.tournament)
    @user.ladder.update_attribute :position, 2
    @quiz.tournament.refresh_scores!

    @user.ladder.update_attribute :score, 10
    l1.reload
    l2.reload

    @user.ladder.up.should == true
    @user.ladder.down.should == false
    l1.up.should == nil
    l1.down.should == nil
    l2.up.should == false
    l2.down.should == true

    l1.update_attribute :score, 8
    @user.ladder.reload
    l2.reload

    @user.ladder.up.should == true
    @user.ladder.down.should == false
    l1.up.should == true
    l1.down.should == false
    l2.up.should == false
    l2.down.should == true
  end
  
  it 'should update combined score' do
    @quiz.tournament.refresh_scores!
    @ladder.update_combined_score
    @ladder.reload.combined_score.should == 6
  end

  it "should count combined score without wingmen" do
    Relation.destroy_all
    @quiz.tournament.refresh_scores!
    @ladder.reload.count_combined_score.should == 6
  end

  it "should count combined score with wingmen having ladders" do
    @wingman = Factory(:user, :email => "wingman@example.com")
    Factory(:ladder, :user => @wingman, :tournament => @quiz.tournament, :score => 10)
    @relation = Factory(:email_relation, :user => @user, :wingman => @wingman, :state => "active")
    @quiz.tournament.refresh_scores!
    @ladder.reload.count_combined_score.should == 18
  end

  it "should count combined score with wingmen without ladders" do
    @wingman = Factory(:user, :email => "wingman@example.com")
    @relation = Factory(:email_relation, :user => @user, :wingman => @wingman, :state => "active")
    @quiz.tournament.refresh_scores!
    @ladder.reload.count_combined_score.should == 4
  end

  it "update 'wings' information correctly all the time" do
    wingman1 = Factory(:user, :email => "wingman1@example.com")
    wingman2 = Factory(:user, :email => "wingman2@example.com")

    @ladder.wings_count.should == 0
    @ladder.wing1.should be_nil
    @ladder.wing2.should be_nil

    relation1 = Factory(:email_relation, :user => @user, :wingman => wingman1, :state => "active")
    @ladder.reload
    @ladder.wings_count.should == 1
    @ladder.wing1.should be_nil
    @ladder.wing2.should be_nil

    ladder1 = Factory(:ladder, :user => wingman1, :tournament => @quiz.tournament)
    @ladder.reload
    @ladder.wings_count.should == 1
    @ladder.wing1.should == ladder1
    @ladder.wing2.should be_nil

    relation2 = Factory(:email_relation, :user => @user, :wingman => wingman2, :state => "pending")
    @ladder.reload
    @ladder.wings_count.should == 2
    @ladder.wing1.should == ladder1
    @ladder.wing2.should be_nil

    relation2.update_attribute :state, "revoked"
    @ladder.reload
    @ladder.wings_count.should == 1
    @ladder.wing1.should == ladder1
    @ladder.wing2.should be_nil

    relation1.destroy
    @ladder.reload
    @ladder.wings_count.should == 0
    @ladder.wing1.should be_nil
    @ladder.wing2.should be_nil
  end
end