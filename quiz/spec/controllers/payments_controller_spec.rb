require_relative '../spec_helper'

describe PaymentsController do
  
  before(:each) do
    @user = Factory(:user, :credits => 0)
    setup_controller_stubs
  end

  it "creates corresponding payment and sends payment notification Email" do
    Time.stub(:now).and_return(Time.parse("Jan 1 2011"))
    Playspan.stub(:valid_params?).and_return(true)

    post :callback, {"sn"=>"GSWT", "login"=>"sa7eveDaw7", "adminpwd"=>"2HetRa2HubRerUZe", "commtype"=>"PAYMENT", "userid"=>"1", "dtdatetime"=>"20031110123000", "currency"=>"GBP", "amount"=>"0.99", "set_amount"=>"0.99", "sepamount"=>"0.99", "paymentid"=>"CH", "pbctrans"=>"{2B7B1AF7-93B2-489B-A11D-80DCA6AD9F79}", "merchtrans"=>"1-0", "livemode"=>"T", "hash"=>"745ec0a9f715061c3e73458e7a1b3941"}

    assigns(:payment).user.credits.should == 3
    response.body.should == "[OK]|#{Time.now.strftime('%Y%m%d%H%M%S')}|{2B7B1AF7-93B2-489B-A11D-80DCA6AD9F79}|[N/A]"

    Delayed::Worker.new.work_off
    ActionMailer::Base.deliveries.last.subject.should include('Got new payment')
    ActionMailer::Base.deliveries.last.body.should include('99p')    
  end

  it "should correctly calculate credits depending on the cost of each credit" do
    Time.stub(:now).and_return(Time.parse("Jan 1 2011"))
    Tournament.stub(:current).and_return(Tournament.first)
    Tournament.current.update_attribute :cost_pence, 50

    post :callback, {"sn"=>"GSWT", "login"=>"sa7eveDaw7", "adminpwd"=>"2HetRa2HubRerUZe", "dtdatetime"=>"20031110123000", "pbctrans"=>"{0e513188-eb73-4117-b39e-1e13ddf40609}", "sn"=>"GSWT", "commtype"=>"PAYMENT", "currency"=>"GBP", "detail"=>"SINGLE_PURCHASE", "set_amount"=>"2.13", "amount"=>"0.00", "sepamount"=>"2.50", "userid"=>"1", "accountname"=>"65", "livemode"=>"T", "paymentid"=>"CH", "pkgid"=>"none", "merchtrans"=>"1-0", "mirror"=>"pay", "rescode"=>"", "gwtid"=>"", "hash"=>"ce581f4de6826131c4ff01636039d532"}

    assigns(:payment).user.credits.should == 5
    response.body.should == "[OK]|#{Time.now.strftime('%Y%m%d%H%M%S')}|{0e513188-eb73-4117-b39e-1e13ddf40609}|[N/A]"
  end

  it "creates payment with decimal amount" do
    Time.stub(:now).and_return(Time.parse("Jan 1 2011"))
    Playspan.stub(:valid_params?).and_return(true)

    get :callback, {"sn"=>"GSWT", "login"=>"sa7eveDaw7", "adminpwd"=>"2HetRa2HubRerUZe", "commtype"=>"PAYMENT", "userid"=>"1", "dtdatetime"=>"20031110123000", "currency"=>"GBP", "amount"=>"15.00", "set_amount"=>"15.00", "sepamount"=>"15.00", "paymentid"=>"CH", "pbctrans"=>"{2B7B1AF7-93B2-489B-A11D-80DCA6AD9F79}", "merchtrans"=>"1-0", "livemode"=>"T", "hash"=>"3cde7d25e503575afae87ee9358ecfc1"}

    assigns(:payment).user.credits.should == 100
    response.body.should == "[OK]|#{Time.now.strftime('%Y%m%d%H%M%S')}|{2B7B1AF7-93B2-489B-A11D-80DCA6AD9F79}|[N/A]"
  end

  # it "creates payment with set_amount smaller than sepamount" do
  #   Time.stub(:now).and_return(Time.parse("Jan 1 2011"))
  # 
  #   get :callback, {"login"=>"sa7eveDaw7", "adminpwd"=>"2HetRa2HubRerUZe", "dtdatetime"=>"20120312202137", "pbctrans"=>"{b69fad08-0db5-4c8f-a0da-0f2af1cab601}", "sn"=>"GSWT", "commtype"=>"PAYMENT", "currency"=>"GBP", "detail"=>"SINGLE_PURCHASE", "set_amount"=>"0.68", "amount"=>"0.00", "sepamount"=>"1.00", "userid"=>"1", "accountname"=>"1", "livemode"=>"T", "paymentid"=>"CH", "pkgid"=>"none", "merchtrans"=>"1", "mirror"=>"pay_and_play", "rescode"=>"", "gwtid"=>"", "hash"=>"f46450c0cb6cad8efd40574818052960"}
  # 
  #   assigns(:payment).user.credits.should == 1.00
  #   response.body.should == "[OK]|#{Time.now.strftime('%Y%m%d%H%M%S')}|{b69fad08-0db5-4c8f-a0da-0f2af1cab601}|[N/A]"
  # end

  it "generates error when called with bad hash" do
    Time.stub(:now).and_return(Time.parse("Jan 1 2011"))

    get :callback, {"sn"=>"GSWT", "login"=>"sa7eveDaw7", "adminpwd"=>"2HetRa2HubRerUZe", "commtype"=>"PAYMENT", "userid"=>"1", "dtdatetime"=>"20031110123000", "currency"=>"GBP", "amount"=>"1.00", "set_amount"=>"1.00", "paymentid"=>"CH", "pbctrans"=>"{2B7B1AF7-93B2-489B-A11D-80DCA6AD9F79}", "merchtrans"=>"1-0", "livemode"=>"T", "hash"=>"f46450c0cb6cad8efd40574818052960"}

    assigns(:payment).status.should == "ERROR"
    response.body.should == "[ERROR]|#{Time.now.strftime('%Y%m%d%H%M%S')}|{2B7B1AF7-93B2-489B-A11D-80DCA6AD9F79}|[N/A]"
  end

  it "should allow admin reversals" do
    @user.update_attribute :credits, 5
    Tournament.stub(:current).and_return(Tournament.first)
    Tournament.current.update_attribute :cost_pence, 100
    Time.stub(:now).and_return(Time.parse("Jan 1 2011"))

    get :callback, {"login"=>"sa7eveDaw7", "adminpwd"=>"2HetRa2HubRerUZe", "dtdatetime"=>"20120330125839", "pbctrans"=>"{cc08f638-b528-4e92-ad61-1af0fc3f993e}", "sn"=>"GSWT", "commtype"=>"ADMIN_REVERSAL", "currency"=>"GBP", "detail"=>"CORRECTION", "set_amount"=>"-4.54", "amount"=>"0.00", "sepamount"=>"-5.00", "userid"=>"1", "accountname"=>"1", "pkgid"=>"none", "merchtrans"=>"1-0", "mirror"=>"pay", "hash"=>"530dd6bcc05565e8cdb255ad51f3b00b"}

    assigns(:payment).user.credits.should == 0
    response.body.should == "[OK]|#{Time.now.strftime('%Y%m%d%H%M%S')}|{cc08f638-b528-4e92-ad61-1af0fc3f993e}|[N/A]"    
  end

  it "should return OK status on the when service number is wrong" do
    Time.stub(:now).and_return(Time.parse("Jan 1 2011"))

    get :callback, {"sn"=>"XXXX", "login"=>"sa7eveDaw7", "adminpwd"=>"2HetRa2HubRerUZe", "commtype"=>"PAYMENT", "userid"=>"1", "dtdatetime"=>"20031110123000", "currency"=>"GBP", "amount"=>"1.00", "set_amount"=>"1.00", "sepamount"=>"1.00", "paymentid"=>"CH", "pbctrans"=>"{2B7B1AF7-93B2-489B-A11D-80DCA6AD9F79}", "merchtrans"=>"1-0", "livemode"=>"T", "hash"=>"745ec0a9f715061c3e73458e7a1b3941"}

    response.body.should == "[OK]|#{Time.now.strftime('%Y%m%d%H%M%S')}|{2B7B1AF7-93B2-489B-A11D-80DCA6AD9F79}|[N/A]"
  end
end
