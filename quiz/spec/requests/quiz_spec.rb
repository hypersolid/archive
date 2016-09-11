require_relative "../spec_helper"

describe "The game should" do
  before(:each) do
    DatabaseCleaner.clean
    @delay = 5
    @minor_delay = 3
    @major_delay = 7

    @user = Factory(:user)
    @tournament = Factory(:tournament)
    @prize = Factory(:prize, :tournament => @tournament)
    10.times do 
      Factory(:question)
    end

    Mogli::User.should_receive(:find).and_return([])
    visit "/users/auth/facebook/callback?code=AQBbGOPqhlrlpTwd0a7kTkxdz4IjaCLYa4FICcl7ZGETWS69LAKeZh9I7mvvjNmfik8P_ZIURqkvaIq4cpHiSeEtIgV4ANSsMOyUfkSb1q5kbzL_TMBCtXXXCrN_szDNzDbEfA0V9fMUQWJ3iJR-EttSs8y7WqshTJJmNSlDCXXg6DYcIxHlzPxV7PDkzxe_bpA"
    page.should have_content("Log Out")
    visit new_quiz_path
  end

  it "give and charge credits appropriately" do
    @user.reload.credits.should == @tournament.new_user_credits - 2
    visit new_quiz_path
    page.should have_content("Play game")
    @user.reload.credits.should == @tournament.new_user_credits - 3
  end

  it "allow to answer correctly", :js => true do
    click_link "Play game"
    sleep @minor_delay

    page.should have_content("Question 1")
    click_link "Correct answer"
    sleep @major_delay

    page.should have_content("Question 2")
    click_link "Correct answer"
    sleep @major_delay

    page.should have_content("Question 3")
  end
  
  it "allow to answer incorrectly", :js => true do
    click_link "Play game"
    sleep @minor_delay

    page.should have_content("Question 1")
    click_link "Correct answer"
    sleep @major_delay
    
    page.should have_content("Question 2")
    click_link "Wrong answer 2"
    sleep @delay

    page.should have_content("Results after 2 questions")
  end

  it "should show popups on the first play", :js => true do
    Quiz.destroy_all
    visit new_quiz_path

    find('#welcome_dialog .start_playing_button').click
    click_link "Play game"
    sleep @minor_delay
    
    page.should have_content("Question 1")
    click_link "Correct answer"
    sleep @delay

    find('#quiz_scorer_popup .next_step').click
    sleep @minor_delay

    find('#quiz_stats').visible?.should be_true
    find('#quiz_stats_popup .next_step').click
    sleep @minor_delay
    
    page.should have_content("Question 2")
    find('#hourglass').visible?.should be_true
    find('#quiz_pass_popup .next_step').click
    sleep @minor_delay

    find('#hourglass').visible?.should be_false
  end 
  
  it "end the game when time is up", :js => true do
    click_link "Play game"
    sleep @minor_delay + @tournament.time_limit
    page.should have_content("Results after 0 questions")
  end
  
  it "allow to pass only fixed amount of questions", :js => true do
    click_link "Play game"
    sleep @minor_delay

    @tournament.passes.times do |i|
      click_link "pass_button"
      sleep @delay
      
      page.should have_content("Question #{i + 2}")
      find('.passes_left').should have_content("#{@tournament.passes - (i + 1)} LEFT")
    end
  end
  
  it "assign points correctly", :js => true do
    click_link "Play game"
    sleep @minor_delay

    click_link "Correct answer"
    points1 = find('#bubble .platform').text.to_i
    sleep @major_delay

    click_link "Correct answer"
    points2 = find('#bubble .platform').text.to_i
    sleep @major_delay

    page.should have_content("Question 3")
    bonuses = 2 * (@tournament.best_time_bonus + @tournament.avg_time_bonus)
    find('#round_score').should have_content((points1 + points2 + bonuses).to_s)
  end
  
  it "animate scorer properly", :js => true do
    seconds = 2
    
    click_link "Play game"
    sleep @minor_delay
    
    points1 = find('#bubble .platform').text.to_i
    time1 = find('#seconds_left').text.to_i
    
    sleep seconds

    points2 = find('#bubble .platform').text.to_i
    time2 = find('#seconds_left').text.to_i
    
    (points1 - points2).should >= @tournament.points_per_second * seconds
    (time1 - time2).should >= seconds
    (points1 - points2).should <= @tournament.points_per_second * (seconds + 1)
    (time1 - time2).should <= seconds + 1
  end
  
  it "show next user & prize", :js => true do
    4.times do |i|
      u = Factory(:user, :email => "place#{i}@example.com")
      Factory(:ladder, :user => u, :score => @tournament.points_max * (i + 1), :tournament => @tournament)
    end 
    Tournament.current.refresh_scores!
    
    click_link "Play game"
    sleep @minor_delay

    click_link "Correct answer"
    sleep @major_delay
    
    find('#next_prize_at').text.gsub(',','').to_i.should == Ladder.all[0].combined_score
    find('#next_friend_at').text.gsub(',','').to_i.should == Ladder.all[3].combined_score 

    click_link "Correct answer"
    sleep @major_delay * 2

    find('#next_prize_at').text.gsub(',','').to_i.should == Ladder.all[0].combined_score
    find('#next_friend_at').text.gsub(',','').to_i.should == Ladder.all[2].combined_score     
  end
  
  it "render 'game over' screen appropriately", :js => true do
    winner = Factory(:user, :email => 'winner@gmail.com')
    looser = Factory(:user, :email => 'looser@gmail.com')
    Factory(:ladder, :user => winner, :score => 300, :tournament => @tournament)
    Factory(:ladder, :user => looser, :score => 200, :tournament => @tournament)
    @user.ladder.update_attribute :score, 100
    @tournament.refresh_scores!

    visit new_quiz_path  
    click_link "Play game"
    sleep @minor_delay
    
    click_link "Correct answer"
    sleep @major_delay * 2
    
    click_link "Wrong answer 2"
    sleep @major_delay
    
    page.should have_content("Results after 2 questions")
    find('.achievements').should have_content('moved')
    find('.achievements').should have_content('1st')
  end
  
  it "block interface on pass event", :js => true do
    click_link "Play game"
    sleep @minor_delay

    click_link "pass_button"
    
    click_link "Correct answer"
    click_link "Wrong answer 1"
    click_link "Wrong answer 2"
    click_link "pass_button"
    sleep @minor_delay
    
    find('.passes_left').should have_content("#{@tournament.passes - 1} LEFT")
  end
  
  it "block interface on right answer", :js => true do
    click_link "Play game"
    sleep @minor_delay

    click_link "Correct answer"

    click_link "Correct answer"
    click_link "Wrong answer 1"
    click_link "Wrong answer 2"
    click_link "pass_button"
    sleep @delay
    
    page.should have_content("Question 2")
  end
  
  it "block interface on wrong answer", :js => true do
    click_link "Play game"
    sleep @minor_delay

    click_link "Wrong answer 1"

    click_link "Correct answer"
    click_link "Wrong answer 1"
    click_link "Wrong answer 2"
    click_link "pass_button"
    sleep @delay
    
    page.should have_content("Results after 1 question")
  end
  
  it "pass question on refresh page", :js => true do
    visit quiz_quiz_path
    page.should have_content("Question 2")
    sleep @minor_delay
    page.should have_content("1 LEFT")
    
    visit quiz_quiz_path
    page.should have_content("Question 3")
    sleep @minor_delay
    page.should have_content("0 LEFT")
    
    visit quiz_quiz_path
    page.should have_content("Results after 2 questions")
    
    visit quiz_quiz_path
    page.should have_content("Play game")
  end
end