require_relative "../spec_helper"

describe "'The Ladder' page should" do
  before(:each) do
    Delayed::Worker.delay_jobs = false

    @delay = 3
    @minor_delay = 2
    @major_delay = 10
    
    @tournament = Factory(:tournament)
    Factory(:prize, :tournament => @tournament)
    15.times do |i|
      u = Factory(:user, :email => "place#{i}@example.com", :name => "User#{i}", :facebook_uid => nil)
      Factory(:ladder, :user => u, :score => 100 * i, :tournament => @tournament)
    end
    
    @user = Factory(:user)
    Factory(:ladder, :user => @user, :tournament => @tournament, :score => 400)
    Factory(:email_relation, :user => @user, :wingman => User.first, :state => 'active')
    Factory(:quiz, :user => @user, :tournament => @tournament)
    @tournament.refresh_scores!
    @user.reload

    Mogli::User.should_receive(:find).and_return([])
    visit "/users/auth/facebook/callback?code=AQBbGOPqhlrlpTwd0a7kTkxdz4IjaCLYa4FICcl7ZGETWS69LAKeZh9I7mvvjNmfik8P_ZIURqkvaIq4cpHiSeEtIgV4ANSsMOyUfkSb1q5kbzL_TMBCtXXXCrN_szDNzDbEfA0V9fMUQWJ3iJR-EttSs8y7WqshTJJmNSlDCXXg6DYcIxHlzPxV7PDkzxe_bpA"
  end

  it "show current user's stats and wingmen" do
    find('#wingmen_panel .stats .wingmen_column4').text.gsub(',','').to_i.should == @user.ladder.combined_score
    find('#wingmen_panel .buttons .wingmen_column2').should have_content(@user.wingmen.first.name)
  end

  it "show any users's stats", :js => true do
    sleep @minor_delay
    find(".tabs .tab[@filter='3']").click
    sleep @minor_delay

    find('#ladder_rows_3 .row:first').click
    sleep @minor_delay
    find('#wingmen_panel_overlay .stats .wingmen_column4').text.should == score(Ladder.all[0].combined_score)

    find('#ladder_rows_3 .row:last').click
    sleep @minor_delay
    find('#wingmen_panel_overlay .stats .wingmen_column4').text.should == score(Ladder.all[9].combined_score)
  end

  it "show the overlay by hash URL", :js => true  do
    @ladder = Ladder.first
    visit ladders_path
    visit root_path + "#ladders/#{@ladder.id}/overlay"
    page.find("#overlay_panel").should be_visible
    page.find("#overlay_panel").should have_content("Write something on #{@ladder.user.name}'s wall:")
  end

  it "show next prize ladder on wingmen_panel" do
    note = find('#wingmen_panel .note').text
    note.should have_content("position on the ladder is #{@user.ladder.position}")
    note.should have_content("prize position is #{@user.ladder.next_prize.position}")
    note.should have_content("1,000")

    @user.ladder.update_attribute :score, 1e7
    
    visit ladders_path
    prize = find('#wingmen_panel .buttons .wingmen_column4').text
    prize.should have_content("winning");
    prize.should have_content("1,000");
  end

  it "allow to switch through tabs", :js => true do
    sleep 1
    find(".tabs .tab[@filter='1']").click
    find("#ladder_rows_1").should have_content(@user.name)
    current_row = find(:xpath, "//div[@id='ladder_rows_1']//div[contains(@class, 'current')]/../..")
    current_row['data-position'].to_i.should == @user.ladder.position

    find(".tabs .tab[@filter='2']").click
    find("#ladder_rows_2").should have_content(@user.name)
    find("#ladder_rows_2").should have_content(@user.wingmen.first.name)

    find(".tabs .tab[@filter='3']").click
    find("#ladder_rows_3").should have_css(".row", :count=>10)
  end

  it "to perpetually scroll ladder up & down", :js => true do
    23.times do |i|
      u = Factory(:user, :email => "upper_place#{i}@example.com", :name => "User #{i}")
      Factory(:ladder, :user => u, :score => 1000 * i, :tournament => @tournament)
    end
    @user.ladder.update_attribute :score, 1000 * 12
    Tournament.current.refresh_scores!

    visit ladders_path
    button_up = find('#ladders_scroller .bt_show_more_up')
    button_down = find('#ladders_scroller .bt_show_more_down')
    button_up_text = button_up.find('.text')
    button_down_text = button_down.find('.text') 

    # Check that buttons are visible and current row is displayed correctly
    assert button_up_text.visible? 
    assert button_down_text.visible? 
    find("#ladder_rows_1 .row:first")['data-position'].to_i.should == 14
    find("#ladder_rows_1 .row:last")['data-position'].to_i.should == 23

    # Check that rows are dynamically loaded when we move up
    button_up.click
    sleep @minor_delay
    find("#ladder_rows_1 .row:first")['data-position'].to_i.should == 1
    find("#ladder_rows_1 .row:last")['data-position'].to_i.should == 23

    # Check that rows are dynamically loaded when we move down
    button_down.click
    sleep @minor_delay
    button_down.click
    sleep @minor_delay
    find("#ladder_rows_1 .row:first")['data-position'].to_i.should == 1
    find("#ladder_rows_1 .row:last")['data-position'].to_i.should == 39

    # Check that buttons 'Show more' are displayed correctly on the bottom
    4.times do |i|
      button_down.click
      sleep @minor_delay
    end
    assert button_up_text.visible? 
    assert !button_down_text.visible?

    #Check that buttons 'Show more' are displayed correctly on the top
    8.times do |i|
      button_up.click
      sleep @minor_delay
    end
    assert !button_up_text.visible? 
    assert button_down_text.visible?
  end

  it "update positions via PusherApp / simple case", :js => true  do
    bad_guy = User.find_by_email("place7@example.com")
    @user.ladder.update_attribute   :score, 2e4
    bad_guy.ladder.update_attribute :score, 1e4
    visit ladders_path

    sleep @minor_delay
    bad_guy.ladder.update_attribute :score, 3e4
    sleep @minor_delay

    first_row = find('#ladder_rows_1 .row:first')
    current_row = find(:xpath, "//div[@id='ladder_rows_1']//div[contains(@class, 'current')]/../..")      
    
    first_row.text.should have_content(score(bad_guy.ladder.combined_score))
    assert first_row.find('.arrow_up').visible?
    assert !first_row.find('.arrow_down').visible?
    
    current_row['data-position'].to_i.should == 2
    assert !current_row.find('.arrow_up').visible?
    assert current_row.find('.arrow_down').visible?
    current_row.find('.current')

    @user.ladder.update_attribute :score, 4e4
    sleep @minor_delay
    first_row = find('#ladder_rows_1 .row:first')
    first_row.find('.current')
  end

  it "update positions via PusherApp / leader's ladder", :js => true  do
    sleep @minor_delay
    find(".tabs .tab[@filter='3']").click

    sleep @minor_delay
    @user.wingman1.update_score 1e7
    sleep @major_delay

    first_row = all('#ladder_rows_3 .row')[0]
    current_row = all('#ladder_rows_3 .row')[1]

    first_row.text.should have_content(@user.wingman1.name)
    current_row.text.should have_content(@user.name)
  end

  it "update positions via PusherApp / winner row goes beyond the ladder", :js => true  do
    bad_guy = User.find_by_email("place7@example.com")
    bad_guy.ladder.update_attribute :score, 100
    
    visit ladders_path
    row_count = all('.scroller .row').count
    sleep @minor_delay
    
    bad_guy.ladder.update_attribute :score, 1e7
    sleep @major_delay

    first_row = find('#ladder_rows_1 .row:first')
    current_row = find(:xpath, "//div[@id='ladder_rows_1']//div[contains(@class, 'current')]/../..")
    first_row.text.should have_content(Ladder.find_by_position(first_row['data-position']).user.name)
    current_row.text.should have_content(@user.name)
    
    all('.scroller .row').each do |row|
      assert !row.find('.arrow_up').visible?
      assert row.find('.arrow_down').visible?
    end
    
    page.should_not have_content(bad_guy.name)
    all('.scroller .row').count.should == row_count
  end

  it "update positions via PusherApp / winner row goes from below the ladder", :js => true  do
    bad_guy = User.find_by_email("place7@example.com")
    @user.ladder.update_attribute :score, 2e7
    bad_guy.ladder.update_attribute :score, 0

    visit ladders_path
    row_count = all('.scroller .row').count
    sleep @minor_delay

    bad_guy.ladder.update_attribute :score, 1e7
    sleep @major_delay

    rows = all('.scroller .row')
    rows[1].text.should have_content(bad_guy.name) 
    rows.count.times do |i|
      if i < 2
        assert rows[i].find('.arrow_up').visible? 
        assert !rows[i].find('.arrow_down').visible?
      else
        assert !rows[i].find('.arrow_up').visible? 
        assert rows[i].find('.arrow_down').visible?
      end
    end
    
    all('.scroller .row').count.should == row_count
  end

  it "update positions via PusherApp / winner row goes through", :js => true  do
    bad_guy = User.find_by_email("place7@example.com")
    @user.ladder.update_attribute :score, 1500
    bad_guy.ladder.update_attribute :score, 0

    visit ladders_path
    row_count = all('.scroller .row').count
    sleep @minor_delay
    
    current_user_position = find(:xpath, "//div[@id='ladder_rows_1']//div[contains(@class, 'current')]/../..")['data-position'].to_i

    bad_guy.ladder.update_attribute :score, 1e7
    sleep @major_delay
    
    current_row = find(:xpath, "//div[contains(@class, 'scroller')]//div[contains(@class, 'current')]/../..")
    current_row['data-position'].to_i.should == current_user_position + 1
    
    all('.scroller .row').each do |current_row|
      assert !current_row.find('.arrow_up').visible? 
      assert current_row.find('.arrow_down').visible?
    end
    
    all('.scroller .row').count.should == row_count
  end

  it "update positions via PusherApp / random movements", :js => true  do
    debug = false
    
    Relation.destroy_all
    @user.reload.ladder.update_attribute  :score, 750
    visit ladders_path
    row_count = all('.scroller .row').count
    start_position = find(".scroller .row:first")['data-position'].to_i
    end_position = find(".scroller .row:last")['data-position'].to_i
    position_range = [start_position, end_position]
    sleep @minor_delay
    
    10.times do |i|
      ladder = Ladder.all.sample(1).first
      old_position = ladder.position
      ladder.update_attribute :score, ladder.score + Random.rand(1e5)
      new_position = ladder.position
      
      if debug
        puts "Step: #{i+1}"
        include_old = position_range.include?(old_position)
        include_new = position_range.include?(new_position)
        t = 'inner' if include_old && include_new
        t = 'over the top' if include_old && !include_new
        t = 'from below' if !include_old && include_new
        t = 'outer' if !include_old && !include_new
        puts "#{ladder.user.name} from #{old_position} to #{new_position} [#{t}]" 
      end
      
      sleep @major_delay
      
      rows = all('.scroller .row .name .valign')
      offset = find('.row:first')['data-position'].to_i - 1
      ladders = Ladder.all[offset, rows.count]
      
      if debug
        puts "start from -> #{offset + 1}"
        p ladders.map(&:user).flatten.map(&:name)
        p rows.map{|v| v.text.split("\n")[0]}
      end
      
      rows.count.times do |i|
        rows[i].text.should have_content(ladders[i].user.name)
      end
    end
    
    all('.scroller .row').count.should == row_count
  end
/
  it "update positions via PusherApp | intensive movement", :js => true  do
    debug = 1
    
    Relation.destroy_all
    @tournament.refresh_scores!
    visit ladders_path
    
    10.times do |i|
      ladder = Ladder.all.sample(1).first
      ladder.update_attribute :score, ladder.score + Random.rand(1e5)
    end
    
    sleep @major_delay * 2
    
    rows = all('.scroller .name .valign')
    offset = find('.row:first')['data-position'].to_i - 1
    ladders = Ladder.all[offset, rows.count]
    if debug
      p ladders.map(&:user).flatten.map(&:name)
      p rows.map{|v| v.text.split("\n")[0]}
    end
    rows.count.times do |i|
      rows[i].text.should have_content(ladders[i].user.name)
    end
  end
/
  it "limit functionality when there's no active tournament"  do
    @tournament.update_attribute :ends_at, Date.yesterday
    visit ladders_path
    page.should have_content('Next tournament coming soon')
  end

  it "show user's wall and status"  do
    @user.update_attribute :status_message, 'test_status'
    Factory(:wall_message, :recipient => @user, :sender => @user)
    visit ladders_path
    page.should have_content('test_status')
    page.should have_content(WallMessage.first.text)
  end

  it "allow to change user's status", :js => true  do
    visit ladders_path
    current_row = find(:xpath, "//div[contains(@class, 'scroller')]//div[contains(@class, 'current')]/../..")
    current_row.find('.inplace-editor').click
    current_row.fill_in 'inplace_value', :with => "test_status"
    current_row.native.send_key(:enter)
    sleep 2
    @user.reload.status_message.should == 'test_status'
  end

  it "paginate messages", :js => true  do
    7.times do |i|
      Factory(:wall_message, :recipient => @user, :sender => @user, :text => "message#{i}", :created_at => i.minutes.from_now)
    end
    visit ladders_path
    all('.message').count.should == 5
    click_link "Show more"
    sleep 2
    all('.message').count.should == 7
    find('#wingmen_panel_wall').should_not have_content("Show more")
  end

  it "allow to write on the other user's wall", :js => true  do
    visit ladders_path
    row = all('.scroller .row')[-2]
    row.click
    sleep 2
    find('#wingmen_panel_overlay_wall').fill_in 'wall_message[text]', :with => "test_message"
    find('#wingmen_panel_overlay_wall input').native.send_key(:enter)
    sleep 2
    WallMessage.count.should == 1
    message = WallMessage.first
    message.sender.should == @user
    message.recipient.should == @tournament.ladders[row['data-position'].to_i-1].user
    message.text.should == "test_message"
  end

  it "allow admin to edit statuses", :js => true  do
    visit ladders_path
    page.has_no_css? '.scroller .row:last .inplace-editor'

    @user.update_attribute :admin, true
    visit ladders_path
    row = all('.scroller .row')[-2]
    row.find('.inplace-editor').click
    row.fill_in 'inplace_value', :with => "test_status"
    row.native.send_key(:enter)
    sleep 2
    user = @tournament.ladders[row['data-position'].to_i-1].user
    user.reload.status_message.should == 'test_status'
  end

  it "allow admin to delete wall posts", :js => true  do
    Factory(:wall_message, :recipient => @user, :sender => @user, :text => "message")
    
    visit ladders_path
    page.has_no_css? '.wall .delete a'

    @user.update_attribute :admin, true
    visit ladders_path
    find('.wall .delete a').click
    sleep 1
    all('.message').count.should == 0
    WallMessage.count.should == 0
  end

end