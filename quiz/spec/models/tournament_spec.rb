require_relative "../spec_helper"

describe Tournament do
  before(:each) do
    @tournament = Factory(:tournament)
  end

  it "should select correct tournament with #current method" do
    Tournament.current.should == @tournament
    @tournament.active?.should be_true

    @tournament.update_attribute :ends_at, 10.days.ago
    Tournament.current.should == @tournament
    @tournament.active?.should be_false

    tournament2 = Factory(:tournament, :starts_at => 2.days.from_now, :ends_at => 10.days.from_now)
    Tournament.current.should == @tournament
    @tournament.active?.should be_false
  end

  it "should return average score when deploy average score is enabled" do
    @tournament.deploy_average_scoring = true
    @tournament.avg_score.should == 10000
  end

  it "should return zero when deploy average score is disabled" do
    @tournament.deploy_average_scoring = false
    @tournament.avg_score.should == 0
  end

  it "should send final summary emails" do
    user = Factory(:user)
    @tournament.update_attributes!(:starts_at => 1.week.ago, :ends_at => 10.minutes.ago)
    Factory(:ladder, :tournament => @tournament, :user => user)

    Tournament.current.send_final_summary!

    # Factory settings
    last_email.to.should include("user@example.com")
    last_email.body.should include("1st")
    last_email.body.should include("11,000")
  end

  it "should NOT send fianl summary emails to users which turned them off" do
    user = Factory(:user, :email_final_summary => false)
    Factory(:ladder, :tournament => @tournament, :user => user)

    EmailFallback.should_not_receive(:proxy)
    Tournament.current.send_final_summary!
  end

  it "should sort ladders on #refresh_scores!" do
    Factory(:ladder, :combined_score => 10, :position => 3, :user => Factory(:user, :email => 'l1@ex.ex'), :tournament => @tournament)
    Factory(:ladder, :combined_score => 2,  :position => 1, :user => Factory(:user, :email => 'l2@ex.ex'), :tournament => @tournament)
    Factory(:ladder, :combined_score => 5,  :position => 2, :user => Factory(:user, :email => 'l3@ex.ex'), :tournament => @tournament)
    Factory(:ladder, :combined_score => 7,  :position => 1, :set_at => Time.now - 1.hour, :user => Factory(:user, :email => 'l5@ex.ex'), :tournament => @tournament)
    Factory(:ladder, :combined_score => 7,  :position => 2, :set_at => Time.now - 2.hours, :user => Factory(:user, :email => 'l4@ex.ex'), :tournament => @tournament)

    @tournament.refresh_scores!

    ladder = [['l1@ex.ex', 1],
              ['l4@ex.ex', 2],
              ['l5@ex.ex', 3],
              ['l3@ex.ex', 4],
              ['l2@ex.ex', 5]]
    Ladder.all.map{|l| [l.user.email,l.position]}.to_set.should == ladder.to_set
  end

  it "should refresh combined_scores & positions on #refresh_scores!" do
    Factory(:ladder, :score => 10, :user => Factory(:user, :email => 'l1@ex.ex'), :tournament => @tournament)
    Factory(:ladder, :score => 0, :user => Factory(:user, :email => 'l2@ex.ex'), :tournament => @tournament)
    Factory(:ladder, :score => 2, :user => Factory(:user, :email => 'l3@ex.ex'), :tournament => @tournament)
    Factory(:ladder, :score => 4, :set_at => Time.now - 1.hour, :user => Factory(:user, :email => 'l5@ex.ex'), :tournament => @tournament)
    Factory(:ladder, :score => 4, :set_at => Time.now - 2.hours, :user => Factory(:user, :email => 'l4@ex.ex'), :tournament => @tournament)

    @tournament.refresh_scores!

    ladder = [['l1@ex.ex', 1, 18],
              ['l4@ex.ex', 2, 12],
              ['l5@ex.ex', 3, 12],
              ['l3@ex.ex', 4, 10],
              ['l2@ex.ex', 5, 8]]
    Ladder.all.map{|l| [l.user.email,l.position, l.combined_score]}.to_set.should == ladder.to_set
  end

end