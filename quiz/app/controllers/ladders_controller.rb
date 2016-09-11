class LaddersController < ApplicationController
  # number of rows for the infinity scroll
  # should be more than 9
  @@result_set_size = 10

  layout "application", :except => [:list_ladders, :fetch_ladders]

  def index
    redirect_to new_quiz_url, :notice => flash[:alert] and return if signed_in? && current_user.should_play_quiz?

    if current_tournament
      @ladder = signed_in? ? current_user.ladder : nil
      self.list_ladders

      if signed_in?
        @show_nudge_popup = (current_user.popup_nudge && current_user.relations.where(:state => :active).count == 2)
        current_user.update_attribute :popup_nudge, false if @show_nudge_popup
      end
    else
      render :text => "We are sorry, the tournament has not yet started."
    end
  end

  # initialize/fill ladders page tabs
  def list_ladders
    session[:ladder_filter] = (params[:filter] or session[:ladder_filter] or 1)
    @filter = session[:ladder_filter].to_i
    if signed_in?
      @ladders = case @filter
        when 1
          current_user.ladder ? current_tournament.ladders_near(current_user.ladder) : current_tournament.ladders.limit(@@result_set_size) 
        when 2
          current_tournament.ladders.where(:user_id => (facebook_signed_in? ? current_user.with_friends : current_user.with_team)).all
        when 3
          current_tournament.ladders.limit(@@result_set_size)
      end
    else
      @ladders = current_tournament.ladders.limit(@@result_set_size)
    end
  end

  # update infinite scroller
  def fetch_ladders
    offset = params[:offset] ? params[:offset].to_i : nil
    limit = params[:limit] ? params[:limit].to_i : nil
    if offset && limit
      limit = offset < 0  ? limit + offset : limit
      offset = offset < 0 ? 0 : offset

      ladders = current_tournament.ladders.limit(limit).offset(offset).all
      render ladders and return unless ladders.empty?
    end
    render :text => ""
  end

  # render one row in a ladder
  def show
    render current_tournament.ladders.where(:position => params[:id]).first  and return if params[:mode] == 'position'
    render current_tournament.ladders.find(params[:id])
  end

  # refresh wingman panel
  def wingmen_panel
  end

  # render other user's stats
  def overlay
    @ladder = Ladder.find(params[:id])
    render :layout => false
  end

  def remove_wingman
    r = current_user.relations.find(params[:id])
    r.revoke!

    current_user.ladder.update_combined_score if current_user.ladder

    @page = params[:page]
  end

  def pay_wingman
    amount = params[:amount].to_i
    @credits_to_buy = amount - current_user.credits
    if @credits_to_buy > 0
      session[:nudge_wingman_id] = params[:id]
      session[:nudge_amount] = amount
      session[:nudge_message] = params[:message]
    else
      current_user.nudge_wingman(params[:id], amount, params[:message])
    end
  end

  def nudge_wingman
    current_user.nudge_wingman(session[:nudge_wingman_id], session[:nudge_amount], session[:nudge_message])
  end

  def game_over
    if current_question
      if current_user.has_played_one_quiz? && current_user.was_invited?
        EmailFallback.proxy(:has_played_email, current_user)
      end

      @questions_answered = current_user.quizzes.last.questions_answered

      # Assemble achievement messages
      position = current_user.ladder.position
      @achievements = []
      @achievements << (position < session[:start_position] ? {:type => 'move_up', :places => session[:start_position] - position} : {:type => 'retain'}) if session[:start_score] > 0
      @achievements << {:type => 'prize', :amount => current_user.ladder.prize} if current_user.ladder.prize > 0
      threshold_period = 10000
      threshold = current_user.ladder.score.div(threshold_period) * threshold_period
      @achievements << {:type => 'threshold', :threshold =>  threshold} if session[:start_score] < threshold
      @achievements << {:type => 'position', :position => position}

      @game_over = true
      ladder = current_user.ladder
      current_user.delay.post_fb_feed(ladder) if position < session[:start_position] && ladder.prize > 0

      reset_session
    end

    self.index
    render 'index'
  end
end