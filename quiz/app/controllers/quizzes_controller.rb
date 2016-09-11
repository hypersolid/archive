class QuizzesController < ApplicationController
  before_filter :authenticate_user!, :except => [:new, :quiz]
  before_filter :ensure_current_question, :only => [:answer]
  # before_filter :ensure_current_ladder, :only => [:quiz, :answer]

  layout 'application', :only => [:quiz]

  # payment actions
  def wait
  end

  def error
  end

  def paystatus
    @payment = current_user.payments.where(:created_at => 1.minute.ago..Time.now).first
    render(:nothing => true) and return if @payment.nil?
  end

  # quiz actions
  def new
    unless signed_in? && current_tournament.active?
      set_return_url
      redirect_to ladders_path unless request.xhr?
      return
    end

    reset_session

    # assign credits for Tournament
    current_user.update_attribute(:credits, current_tournament.new_user_credits) if (current_user.quizzes.count == 0) && current_tournament.new_user_credits > 0
    current_user.increment!(:credits, current_tournament.existing_user_credits) if current_user.existing_user_needs_credits? && current_tournament.existing_user_credits > 0

    # find or create ladder
    l = current_tournament.ladders.find_by_user_id(current_user.id)
    l ||= current_tournament.ladders.create!(
      :user_id => current_user.id, 
      :combined_score => 2 * current_tournament.avg_score, 
      :position => current_tournament.ladders.count + 1, 
      :prize => (current_tournament.prizes.where(:position => current_tournament.ladders.count + 1).first.amount rescue 0),
      :set_at => Time.now)

    if current_user.credits > 0 || current_user.admin?
      session[:quiz] = current_tournament.quizzes.create!(:user => current_user, :paid => current_user.pays?)
      current_user.decrement!(:credits) unless current_user.admin?
      session[:start_position] = l.position
      session[:start_score] = l.score
      session[:points] = 0
      redirect_to quiz_quiz_path, :notice => flash[:notice] unless request.xhr?
    else
      session[:quiz] = nil
      redirect_to ladders_path unless request.xhr?
    end
  end

  def bootstrap
    self.new
    self.next_question
  end

  def quiz
    redirect_to ladders_path and return unless current_tournament.active?
    if current_quiz
      if current_question
        @skip_ready_screen = true
        self.pass
      else
        self.next_question
      end
    else
      if signed_in?
        redirect_to new_quiz_path
      elsif params[:request_id]
        # Remember Relation.request_id to attach wingman to user after sign up
        @relation =  Relation.where(:request_id => params[:request_id], :state => "pending").first
        session[:request_id] = @relation ? params[:request_id] : nil
      # elsif params[:ref_id] && request.env["HTTP_USER_AGENT"] !~ /facebookexternalhit/
      #   @relation = Relation.find_or_create_pending_fb_relation(params[:ref_id])
      #   session[:request_id] = @relation.request_id if @relation
      end
    end
  end

  def answer
    redirect_to new_quiz_path and return unless request.xhr?

    unless current_tournament.active?
      params[:answer]=nil
      self.wrong
      session[:quiz] = nil
      render :text => "" , :status => 400
    end

    if params[:score].to_i > 0 && params[:answer] == current_question.correct_answer
      self.correct
      render '/quizzes/next_question'
    elsif params[:answer].blank? && current_quiz.passes_left > 0
      self.pass
      if current_question
        render '/quizzes/next_question'
      else
        session[:quiz] = nil
        render :text => "" , :status => 400
      end
    else
      self.wrong
      session[:quiz] = nil
      render :text => "" , :status => 400
    end
  end

  # Refined actions
  def correct
    claimed_points = params[:score].to_i
    acquired_points = current_tournament.points_with_bonuses(current_user, current_question, claimed_points)

    elapsed_time = current_tournament.time_limit - current_tournament.points_to_time(claimed_points)

    unless current_quiz.answers.empty?
      time_lag = Time.now - session[:next_time] - elapsed_time
    else
      time_lag = nil
    end

    # save the answer
    current_user.answers.create!(
      :question => current_question,
      :tournament => current_tournament,
      :quiz => current_quiz,
      :answer => params[:answer],
      :time => elapsed_time,
      :time_lag => time_lag,
      :claimed_points => claimed_points,
      :acquired_points => acquired_points
    )

    session[:points] += acquired_points
    current_question.update_attribute :avg_time, current_question.answers.average(:time)
    if session[:points] > current_user.ladder.score
      current_user.ladder.update_attributes!(:score => session[:points], :set_at => Time.now)
    end

    self.next_question
  end

  def pass
    if current_quiz.passes_left > 0
      current_user.answers.create!(
        :question => current_question,
        :tournament => current_tournament,
        :quiz => current_quiz
      )
      self.next_question
    else
      session[:quiz] = nil
      if request.xhr?
        render :text => "" , :status => 400
      else
        redirect_to game_over_ladders_path
      end
    end
  end

  def wrong
    current_user.answers.create!(
      :question => current_question,
      :tournament => current_tournament,
      :quiz => current_quiz,
      :answer => params[:answer]
    )
  end
    
  # Final actions
  def next_question
    # tricky logic to pick random question
    required_difficulty = current_tournament.difficulty(current_quiz.answers.where("answer IS NOT NULL").count)
    q = Question.with_difficulty(required_difficulty).for(current_user).sample

    # try to get more difficult questions if no questions left with required difficulty
    q ||= Question.with_difficulty(required_difficulty + 1).for(current_user).sample
    q ||= Question.with_difficulty(required_difficulty + 2).for(current_user).sample
    q ||= Question.with_difficulty(required_difficulty + 3).for(current_user).sample

    session[:next_question] = q
    session[:next_time] = Time.now
    session[:quiz].reload
  end

  private

  def ensure_current_question
    redirect_to root_url unless current_question && current_quiz
  end

  def ensure_current_ladder
    redirect_to new_quiz_path unless current_user.ladder
  end

end