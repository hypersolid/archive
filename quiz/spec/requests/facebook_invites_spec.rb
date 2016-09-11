require_relative "../spec_helper"
=begin
describe "Invite wingman process by facebook" do

  before :each do
    @quiz = Factory(:quiz)
    @prize = Factory(:prize, :tournament => @quiz.tournament)
    @ladder = Factory(:ladder, :tournament => @quiz.tournament, :user => @quiz.user, :prize => @prize)
    5.times {|i| Factory(:question)}
    @delay = 7
  end

  it "updates wingmen panel and credits box", :js => true do
    Factory(:ladder, :user => @quiz.user, :tournament => @tournament, :score => 400)
    Factory(:quiz, :user => @quiz.user, :tournament => @tournament)
    @quiz.tournament.refresh_scores!

    Mogli::User.should_receive(:find).and_return([])
    visit "/users/auth/facebook/callback?code=AQBbGOPqhlrlpTwd0a7kTkxdz4IjaCLYa4FICcl7ZGETWS69LAKeZh9I7mvvjNmfik8P_ZIURqkvaIq4cpHiSeEtIgV4ANSsMOyUfkSb1q5kbzL_TMBCtXXXCrN_szDNzDbEfA0V9fMUQWJ3iJR-EttSs8y7WqshTJJmNSlDCXXg6DYcIxHlzPxV7PDkzxe_bpA"

    click_on "INVITE"
    page.execute_script "$.post(\"/facebook_invites\");"
    sleep 1
    page.find(".creditsBox .visible").should have_content("2 credits")
    page.should have_content("REMOVE")

    click_on "INVITE"
    page.execute_script "$.post(\"/facebook_invites\");"
    sleep 1
    # page.all("img#get_2_credits").should be_empty
    page.find(".creditsBox .visible").should have_content("4 credits")
  end

  it "registers new user as a wingman of the requesting user", :js => true do
    @quiz.user.update_attribute :facebook_uid, nil
    
    visit quiz_quiz_path(:ref_id => @quiz.user_id, :fb_source => "message")
    page.should have_content("You're moments away")

    Mogli::User.should_receive(:find).and_return([])
    visit "/users/auth/facebook/callback?code=AQBbGOPqhlrlpTwd0a7kTkxdz4IjaCLYa4FICcl7ZGETWS69LAKeZh9I7mvvjNmfik8P_ZIURqkvaIq4cpHiSeEtIgV4ANSsMOyUfkSb1q5kbzL_TMBCtXXXCrN_szDNzDbEfA0V9fMUQWJ3iJR-EttSs8y7WqshTJJmNSlDCXXg6DYcIxHlzPxV7PDkzxe_bpA"

    @quiz.user.reload.wingmen.should include(User.last)
    Relation.first.should be_active
    page.should have_content("Vitaly")
    page.should have_content("Are you ready ?")
    page.should have_content("wingman of #{@quiz.user.name}")

    click_link "Play game"
    sleep @delay
    page.should have_content("Question 1")

    click_link "Correct answer"

    click_link "The Ladder"
    page.should have_content("You are the wingman for #{@quiz.user.name}")
    @quiz.user.credits.should == 4
  end
end
=end