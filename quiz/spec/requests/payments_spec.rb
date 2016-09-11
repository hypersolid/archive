require_relative "../spec_helper"

describe "the payment process" do
  before :each do
    @quiz = Factory(:quiz)
    @prize = Factory(:prize, :tournament => @quiz.tournament)
    @ladder = Factory(:ladder, :tournament => @quiz.tournament, :user => @quiz.user, :prize => Prize.first)
    @question = Factory(:question)

    Mogli::User.should_receive(:find).and_return([])
    visit "/users/auth/facebook/callback?code=AQBbGOPqhlrlpTwd0a7kTkxdz4IjaCLYa4FICcl7ZGETWS69LAKeZh9I7mvvjNmfik8P_ZIURqkvaIq4cpHiSeEtIgV4ANSsMOyUfkSb1q5kbzL_TMBCtXXXCrN_szDNzDbEfA0V9fMUQWJ3iJR-EttSs8y7WqshTJJmNSlDCXXg6DYcIxHlzPxV7PDkzxe_bpA"
    page.should have_content("Log Out")
  end

  it "renders payment popup when game must be paid", :js => true do
    redo_flag = false
    click_link "PLAY NOW"
    sleep 1
    page.all(".pay_credits_button").first.click

    sleep 5
    within_frame "up_payframe" do
      # page.all("#tabs li.tab-plain").last.click
      # page.all(".pay-button-wrapper")[1].find(".paybutton").click
      page.execute_script "util.submitPaymentMethod('ch', 'choose_form_id', 'choosePayButton');"

      payment_in_progress = page.find("#right-content #errorMessage a") rescue nil
      if payment_in_progress
        payment_in_progress.click
        page.find(".closeLBBtn").click
        redo_flag = true
      else
        if page.first("#cc") # pay using new CC
          fill_in "cc", :with => "4444444444444448"
          fill_in "csc", :with => "123"
          select (Time.now.year + 1).to_s, :from => "expYear"
          page.find(".lb_btn_dyn_text").click

          fill_in "nameOnCard", :with => "John Doe"
          fill_in "addr1", :with => "1st Road"
          fill_in "city", :with => "London"
          fill_in "zip", :with => "03101"
          page.find(".lb_btn_dyn_text").click
        else # pay using stored CC
          page.find(".lb_btn_dyn_text").click
        end

        page.find(".lb_btn_dyn_text").click
      end
    end

    redo if redo_flag # try again
    current_path.should == "/ladders" # assert redirect
  end

  it "renders waiting page", :js => true do
    visit "/ladders?token=uxyRpZBastkrrISp2kfxyLTMFkeHOQztdjMAyFSdse3&noLb=1"
    page.should have_content("Applying credits to your account")
  end

  it "redirects to game page when payment mode == pay_and_play", :js => true do
    visit "/ladders?token=uxyRpZBastkrrISp2kfxyLTMFkeHOQztdjMAyFSdse3&noLb=1"
    page.should have_content("Applying credits to your account")

    # process payment
    get "/payments/callback", {"sn"=>"GSWT", "login"=>"sa7eveDaw7", "adminpwd"=>"2HetRa2HubRerUZe", "commtype"=>"PAYMENT", "userid"=>"1", "dtdatetime"=>"20031110123000", "currency"=>"GBP", "amount"=>"1.00", "set_amount"=>"1.00",  "sepamount"=>"1.00", "paymentid"=>"CH", "pbctrans"=>"{2B7B1AF7-93B2-489B-A11D-80DCA6AD9F79}", "merchtrans"=>"1-0", "livemode"=>"T", "mirror" => "pay_and_play", "hash"=>"4e9fc824f76ab1ad127c8ccf1db4d1f8"}

    page.should have_content("Are you ready ?")
  end

  it "displays updated balance when payment mode == pay", :js => true do
    visit "/ladders?token=uxyRpZBastkrrISp2kfxyLTMFkeHOQztdjMAyFSdse3&noLb=1"
    page.find(".creditsBox .visible").should have_content("35p per go")
    page.should have_content("Applying credits to your account")
    page.find('#ui_dialog').visible?.should be_true

    # process payment
    Playspan.stub(:valid_params?).and_return(true)
    get "/payments/callback", {"sn"=>"GSWT", "login"=>"sa7eveDaw7", "adminpwd"=>"2HetRa2HubRerUZe", "commtype"=>"PAYMENT", "userid"=>"1", "dtdatetime"=>"20031110123000", "currency"=>"GBP", "amount"=>"0.99", "set_amount"=>"0.99",  "sepamount"=>"0.99", "paymentid"=>"CH", "pbctrans"=>"{2B7B1AF7-93B2-489B-A11D-80DCA6AD9F79}", "merchtrans"=>"1-0", "livemode"=>"T", "mirror" => "pay", "hash"=>"2b5dc6f06d8cada5180bdc310324701f"}

    page.find(".creditsBox .visible").should have_content("3 credits")
    page.find('#ui_dialog').visible?.should be_false
  end

  it "nudges wingman silently when user has enough credits", :js => true do
    wingman = Factory(:user, :email => "john@example.com", :credits => 0)
    Factory(:facebook_relation, :user => @quiz.user, :wingman => wingman, :state => "active")
    @quiz.user.update_attribute :credits, 6
    @quiz.tournament.update_attribute :cost_pence, 50

    visit "/ladders"
    click_on "SEND CREDITS"
    fill_in "amount", :with => "5"
    fill_in "message", :with => "hey, wingman"
    click_on "Send"
    sleep 1

    page.find('#ui_dialog').visible?.should be_false

    wingman.reload.credits.should == 5
    @quiz.user.reload.credits.should == 1

    last_email.body.should include("hey, wingman")
  end

  it "nudges wingman and sends email", :js => true do
    wingman = Factory(:user, :email => "john@example.com", :credits => 0)
    Factory(:email_relation, :user => @quiz.user, :wingman => wingman, :state => "active")
    @quiz.tournament.update_attribute :cost_pence, 50
    @quiz.user.update_attribute :credits, 1

    visit "/ladders"
    click_on "SEND CREDITS"
    fill_in "amount", :with => "2"
    fill_in "message", :with => "hey, wingman"
    click_on "Send"
    sleep 5

    within_frame "up_payframe" do
      page.should have_content("1 Credit")
    end

    visit "/ladders?token=uxyRpZBastkrrISp2kfxyLTMFkeHOQztdjMAyFSdse3&noLb=1"
    page.should have_content("Applying credits to your account")
    page.find('#ui_dialog').visible?.should be_true
    
    # process payment
    get "/payments/callback", {"sn"=>"GSWT", "login"=>"sa7eveDaw7", "adminpwd"=>"2HetRa2HubRerUZe", "commtype"=>"PAYMENT", "userid"=>"1", "dtdatetime"=>"20031110123000", "currency"=>"GBP", "amount"=>"0.50", "set_amount"=>"0.50", "sepamount"=>"0.50", "paymentid"=>"CH", "pbctrans"=>"{2B7B1AF7-93B2-489B-A11D-80DCA6AD9F79}", "merchtrans"=>"1-0", "livemode"=>"T", "mirror" => "nudge", "hash"=>"abf96c9055c6a550c21b2e2b3fd0ad53"}
    sleep 4
    page.find('#ui_dialog').visible?.should be_false
    
    wingman.reload.credits.should == 2
    @quiz.user.reload.credits.should == 0

    last_email.body.should include("hey, wingman")
  end

  it "redirects to error page when got no payment" do
    visit error_quiz_url
    page.should have_content("We did not receive your payment yet")
  end

  it "allows to buy more credits", :js => true do
    click_on "35p per go"
    page.all(".pay_credits_button").last.click

    within_frame "up_payframe" do
      page.should have_content("Buy 100 Credits")
    end
  end
end