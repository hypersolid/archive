require_relative "../spec_helper"

describe "Invite wingman process by email" do

  before :each do
    Delayed::Worker.delay_jobs = false
    @quiz = Factory(:quiz)
    @prize = Factory(:prize, :tournament => @quiz.tournament)
    @ladder = Factory(:ladder, :tournament => @quiz.tournament, :user => @quiz.user, :prize => @prize)
    5.times {|i| Factory(:question)}
    @delay = 5
  end

  it "Click button 'invite wingman', fill emails and send invites", :js => true do
    # user sign in
    Mogli::User.should_receive(:find).and_return([])
    visit "/users/auth/facebook/callback?code=AQBbGOPqhlrlpTwd0a7kTkxdz4IjaCLYa4FICcl7ZGETWS69LAKeZh9I7mvvjNmfik8P_ZIURqkvaIq4cpHiSeEtIgV4ANSsMOyUfkSb1q5kbzL_TMBCtXXXCrN_szDNzDbEfA0V9fMUQWJ3iJR-EttSs8y7WqshTJJmNSlDCXXg6DYcIxHlzPxV7PDkzxe_bpA"
    page.should have_content("Log Out")

    find('#email_invites_dialog').visible?.should be_false
    click_link "INVITE"
    find('#email_invites_dialog').visible?.should be_true

    within("#email_invites_dialog") do
      fill_in "email1", :with => "invited_user@example.com"
      fill_in "name1", :with => "John"
      fill_in "message", :with => "Hi, let's play together!"
      click_link "Continue"
    end

    page.find(".creditsBox .visible").should have_content("2 credits")
    last_email.to.should include("invited_user@example.com")
    last_email.body.should include(Relation.last.request_id)

    within('#invites_were_sent_dialog') do
      page.should have_content("Invites were sent to:")
      page.should have_content("John")
      page.should have_content("more credits")
      click_link "Invite"
    end

    within('.wingmen_column2 .white_label') do
      page.should have_content("John")
    end

    within("#email_invites_dialog") do
      fill_in "email1", :with => "jack@example.com"
      fill_in "name1", :with => "Jack"
      fill_in "message", :with => "Hi, let's play together!"
      click_link "Continue"
    end

    within('#invites_were_sent_dialog') do
      page.should have_content("Invites were sent to:")
      page.should have_content("Jack")
      page.should_not have_content("more credits")
      click_link "Close window"
    end

    page.find(".creditsBox .visible").should have_content("4 credits")

    within('.wingmen_column3 .white_label') do
      page.should have_content("Jack")
    end

    page.should have_content("REMOVE")
    click_on "REMOVE"
    sleep 1
    click_on "REMOVE"
    sleep 1
    page.should_not have_content("REMOVE")

    click_on "4 credits"
    find('#pay_dialog').visible?.should be_true
    within('#pay_dialog') do
      # page.should_not have_content("Invite a wingman")
      find("a.pay_invite_button").visible?.should be_false
    end
  end

  it "registers new user as a wingman of the requesting user using request_id", :js => true do
    @inviter = Factory(:user, :facebook_uid => 123, :email => "inviter@example.com")
    @existing_relation = Factory(:email_relation, :user => @inviter, :wingman => Factory(:user, :email => "wingman@example.com", :facebook_uid => 1234), :email => "wingman@example.com", :state => "active")
    @relation = Factory(:email_relation, :user => @inviter)
    User.find_by_facebook_uid(1206903360).destroy

    # invited user sign up
    visit quiz_quiz_path(:request_id => @relation.request_id)
    page.should have_content("You're moments away")

    Mogli::User.should_receive(:find).and_return([])
    visit "/users/auth/facebook/callback?code=AQBbGOPqhlrlpTwd0a7kTkxdz4IjaCLYa4FICcl7ZGETWS69LAKeZh9I7mvvjNmfik8P_ZIURqkvaIq4cpHiSeEtIgV4ANSsMOyUfkSb1q5kbzL_TMBCtXXXCrN_szDNzDbEfA0V9fMUQWJ3iJR-EttSs8y7WqshTJJmNSlDCXXg6DYcIxHlzPxV7PDkzxe_bpA"
    page.should have_content("Log Out")

    @inviter.reload.wingmen.should include(User.last)
    @relation.reload.should be_active

    page.should have_content("Are you ready ?")
    page.should have_content("wingman of #{@relation.user.name}")

    click_link "Play game"
    sleep @delay
    page.should have_content("Question 1")
  end

  it "registers existing user as a wingman of the requesting user using request_id", :js => true do
    @inviter = Factory(:user, :facebook_uid => 123, :email => "inviter@example.com")
    @existing_relation = Factory(:email_relation, :user => @inviter, :wingman => Factory(:user, :email => "wingman@example.com", :facebook_uid => 1234), :email => "wingman@example.com", :state => "active")
    @relation = Factory(:email_relation, :user => @inviter)
    User.find_by_facebook_uid(1206903360).quizzes.delete_all

    # invited user sign up
    visit quiz_quiz_path(:request_id => @relation.request_id)
    page.should have_content("You're moments away")

    Mogli::User.should_receive(:find).and_return([])
    visit "/users/auth/facebook/callback?code=AQBbGOPqhlrlpTwd0a7kTkxdz4IjaCLYa4FICcl7ZGETWS69LAKeZh9I7mvvjNmfik8P_ZIURqkvaIq4cpHiSeEtIgV4ANSsMOyUfkSb1q5kbzL_TMBCtXXXCrN_szDNzDbEfA0V9fMUQWJ3iJR-EttSs8y7WqshTJJmNSlDCXXg6DYcIxHlzPxV7PDkzxe_bpA"
    page.should have_content("Log Out")

    @inviter.reload.wingmen.should include(User.last)
    @relation.reload.should be_active

    page.should have_content("Are you ready ?")
    page.should have_content("wingman of #{@relation.user.name}")

    click_link "Play game"
    sleep @delay
    page.should have_content("Question 1")
  end

  it "keeps pending relation in case of inviter clicks their own link", :js => true do
    @inviter = @quiz.user
    @existing_relation = Factory(:email_relation, :user => @inviter, :wingman => Factory(:user, :email => "wingman@example.com", :facebook_uid => 1234), :email => "wingman@example.com", :state => "active")
    @relation = Factory(:email_relation, :user => @inviter)
    # User.find_by_facebook_uid(1206903360).quizzes.delete_all

    # invited user sign up
    visit quiz_quiz_path(:request_id => @relation.request_id)
    page.should have_content("You're moments away")

    Mogli::User.should_receive(:find).and_return([])
    visit "/users/auth/facebook/callback?code=AQBbGOPqhlrlpTwd0a7kTkxdz4IjaCLYa4FICcl7ZGETWS69LAKeZh9I7mvvjNmfik8P_ZIURqkvaIq4cpHiSeEtIgV4ANSsMOyUfkSb1q5kbzL_TMBCtXXXCrN_szDNzDbEfA0V9fMUQWJ3iJR-EttSs8y7WqshTJJmNSlDCXXg6DYcIxHlzPxV7PDkzxe_bpA"
    page.should have_content("Log Out")

    @relation.reload.should be_pending
    page.should_not have_content("wingman of #{@relation.user.name}")
  end

  it "should connect invited user to inviter using Email", :js => true do
    @inviter = Factory(:user, :facebook_uid => 123, :email => "inviter@example.com")
    @existing_relation = Factory(:email_relation, :user => @inviter, :wingman => Factory(:user, :email => "wingman@example.com", :facebook_uid => 1234), :email => "wingman@example.com", :state => "active")
    @relation = Factory(:email_relation, :user => @inviter, :email => "fomichov@gmail.com")
    User.find_by_facebook_uid(1206903360).destroy

    # invited user sign up
    visit root_path
    page.should_not have_content("You're moments away")

    Mogli::User.should_receive(:find).and_return([])
    visit "/users/auth/facebook/callback?code=AQBbGOPqhlrlpTwd0a7kTkxdz4IjaCLYa4FICcl7ZGETWS69LAKeZh9I7mvvjNmfik8P_ZIURqkvaIq4cpHiSeEtIgV4ANSsMOyUfkSb1q5kbzL_TMBCtXXXCrN_szDNzDbEfA0V9fMUQWJ3iJR-EttSs8y7WqshTJJmNSlDCXXg6DYcIxHlzPxV7PDkzxe_bpA"
    page.should have_content("Log Out")

    @inviter.reload.wingmen.should include(User.last)
    @relation.reload.should be_active

    page.should have_content("Are you ready ?")
    page.should have_content("wingman of #{@relation.user.name}")

    click_link "Play game"
    sleep @delay
    page.should have_content("Question 1")
  end

  it "should display invite button on the pay popup", :js => true do
    # user sign in
    Mogli::User.should_receive(:find).and_return([])
    visit "/users/auth/facebook/callback?code=AQBbGOPqhlrlpTwd0a7kTkxdz4IjaCLYa4FICcl7ZGETWS69LAKeZh9I7mvvjNmfik8P_ZIURqkvaIq4cpHiSeEtIgV4ANSsMOyUfkSb1q5kbzL_TMBCtXXXCrN_szDNzDbEfA0V9fMUQWJ3iJR-EttSs8y7WqshTJJmNSlDCXXg6DYcIxHlzPxV7PDkzxe_bpA"
    page.should have_content("Log Out")

    click_on "35p per go"
    find('#pay_dialog').visible?.should be_true
    click_on "Invite a wingman"
    find('#email_invites_dialog').visible?.should be_true
  end
end