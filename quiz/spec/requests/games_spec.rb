require_relative "../spec_helper"

describe "Game process" do
  before :each do
    @tournament = Factory(:tournament)
    @prize = Factory(:prize, :tournament => @tournament)
    @user = Factory(:user)
    @question = Factory(:question)

    Mogli::User.should_receive(:find).and_return([])
  end

  it "allows to play a free game", :js => true do
    @question2 = Factory(:question)
    visit "/users/auth/facebook/callback?code=AQBbGOPqhlrlpTwd0a7kTkxdz4IjaCLYa4FICcl7ZGETWS69LAKeZh9I7mvvjNmfik8P_ZIURqkvaIq4cpHiSeEtIgV4ANSsMOyUfkSb1q5kbzL_TMBCtXXXCrN_szDNzDbEfA0V9fMUQWJ3iJR-EttSs8y7WqshTJJmNSlDCXXg6DYcIxHlzPxV7PDkzxe_bpA"

    # 1st answer
    page.should have_content("Are you ready ?")
    find('#welcome_dialog').visible?.should be_true
    find('#welcome_dialog .start_playing_button').click
    click_on "Play game"
    sleep 3
    find('#welcome_dialog').visible?.should be_false
    click_on @question.correct_answer

    sleep 4
    click_on "Next"
    page.find("#total_score").text.to_i.should_not be_zero
    sleep 1
    click_on "Continue to next question"

    sleep 2
    page.find("#quiz_pass_popup").should have_content("2 passes remaining")
    click_on "Next"
    sleep 4

    # 2nd answer
    click_on @question2.wrong_answers.first

    # game over
    page.should have_content("Results after 2 questions")
  end

  it "requires you to pay before you play when you have no credits left", :js => true  do
    @quiz = Factory(:quiz, :tournament => @tournament, :user => @user)
    @ladder = Factory(:ladder, :tournament => @tournament, :user => @user, :prize => Prize.first)

    visit "/users/auth/facebook/callback?code=AQBbGOPqhlrlpTwd0a7kTkxdz4IjaCLYa4FICcl7ZGETWS69LAKeZh9I7mvvjNmfik8P_ZIURqkvaIq4cpHiSeEtIgV4ANSsMOyUfkSb1q5kbzL_TMBCtXXXCrN_szDNzDbEfA0V9fMUQWJ3iJR-EttSs8y7WqshTJJmNSlDCXXg6DYcIxHlzPxV7PDkzxe_bpA"
    page.should have_content("Log Out")
    click_link "PLAY NOW"
    sleep 1
    page.all(".pay_credits_button").first.click
    sleep 5

    within_frame "up_payframe" do
      page.find(".closeLBBtn").click
    end

    visit "/ladders?token=uxyRpZBastkrrISp2kfxyLTMFkeHOQztdjMAyFSdse3&noLb=1"
    page.should have_content("Applying credits to your account")

    # process payment
    get "/payments/callback", {"sn"=>"GSWT", "login"=>"sa7eveDaw7", "adminpwd"=>"2HetRa2HubRerUZe", "commtype"=>"PAYMENT", "userid"=>"1", "dtdatetime"=>"20031110123000", "currency"=>"GBP", "amount"=>"0.35", "set_amount"=>"0.35", "sepamount"=>"0.35", "paymentid"=>"CH", "pbctrans"=>"{2B7B1AF7-93B2-489B-A11D-80DCA6AD9F79}", "merchtrans"=>"1-0", "livemode"=>"T", "mirror" => "pay_and_play", "hash"=>"f1c4299c15bdfc0e3c9260cb6ec6d156"}

    page.should have_content("Are you ready ?")
    click_on "Play game"
    sleep 2
    click_on @question.wrong_answers.first
    sleep 2
    click_link "PLAY AGAIN"
    sleep 1
    page.all(".pay_credits_button").first.click
    sleep 5

    # assert that next quiz will be paid too
    within_frame "up_payframe" do
      page.all("#tabs li").size.should == 3
      page.find(".closeLBBtn").click
    end
  end

  it "redirects to the ladders page when current quiz is not paid", :js => true do
    @quiz = Factory(:quiz, :tournament => @tournament, :user => @user)
    @ladder = Factory(:ladder, :tournament => @tournament, :user => @user)
    visit "/users/auth/facebook/callback?code=AQBbGOPqhlrlpTwd0a7kTkxdz4IjaCLYa4FICcl7ZGETWS69LAKeZh9I7mvvjNmfik8P_ZIURqkvaIq4cpHiSeEtIgV4ANSsMOyUfkSb1q5kbzL_TMBCtXXXCrN_szDNzDbEfA0V9fMUQWJ3iJR-EttSs8y7WqshTJJmNSlDCXXg6DYcIxHlzPxV7PDkzxe_bpA"

    page.should have_content("Log Out")

    visit "/quiz/new"
    current_path.should == ladders_path

    visit "/quiz/quiz"
    current_path.should == ladders_path
  end

  describe "should be stopped by the 'game over' screen if tournament" do

    it "has ended and user picks the correct answer", :js => true do

      visit "/users/auth/facebook/callback?code=AQBbGOPqhlrlpTwd0a7kTkxdz4IjaCLYa4FICcl7ZGETWS69LAKeZh9I7mvvjNmfik8P_ZIURqkvaIq4cpHiSeEtIgV4ANSsMOyUfkSb1q5kbzL_TMBCtXXXCrN_szDNzDbEfA0V9fMUQWJ3iJR-EttSs8y7WqshTJJmNSlDCXXg6DYcIxHlzPxV7PDkzxe_bpA"

      # 1st answer
      page.should have_content("Are you ready ?")
      find('#welcome_dialog').visible?.should be_true
      find('#welcome_dialog .start_playing_button').click
      click_on "Play game"
      find('#welcome_dialog').visible?.should be_false

      @tournament.update_attribute :ends_at, 1.seconds.from_now
      sleep 2
      click_on @question.correct_answer

      # game over page
      page.should have_content("Results after 1 question")
    end

    it "has ended", :js => true do
      @tournament.update_attribute :ends_at, 10.seconds.from_now

      visit "/users/auth/facebook/callback?code=AQBbGOPqhlrlpTwd0a7kTkxdz4IjaCLYa4FICcl7ZGETWS69LAKeZh9I7mvvjNmfik8P_ZIURqkvaIq4cpHiSeEtIgV4ANSsMOyUfkSb1q5kbzL_TMBCtXXXCrN_szDNzDbEfA0V9fMUQWJ3iJR-EttSs8y7WqshTJJmNSlDCXXg6DYcIxHlzPxV7PDkzxe_bpA"

      # 1st answer
      page.should have_content("Are you ready ?")
      find('#welcome_dialog').visible?.should be_true
      find('#welcome_dialog .start_playing_button').click
      click_on "Play game"
      find('#welcome_dialog').visible?.should be_false

      sleep 8

      # game over page
      page.should have_content("Results after 0 question")
    end
  end
end