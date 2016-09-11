class ApplicationController < ActionController::Base
  protect_from_forgery
  before_filter :check_domain

  helper_method :current_question, :current_tournament, :current_quiz, :current_score, :current_user_photo_url, :facebook_signed_in?, :email_signed_in?, :current_page

  def check_domain
    redirect_to request.protocol + "www.gameshow.co.uk" + request.request_uri if Rails.env.production? && !request.ssl? && request.host !~ /www\.gameshow\.co\.uk/
  end

  def current_page
    params[:controller]
  end

  def current_tournament
    @current_tournament ||= Tournament.current
  end

  def current_question
    session[:next_question]
  end

  def current_quiz
    session[:quiz]
  end

  def current_score
    @current_score ||= current_user.answers.where(:question_id => current_quiz.reload.answers.map(&:question_id)).all.sum(&:points)
  end

  def facebook_signed_in?
    signed_in? && !session[:auth].blank? && session[:auth]['provider'] == 'facebook'
  end

  def email_signed_in?
    signed_in? && !facebook_signed_in?
  end

  def validate_email(email)
    !email.blank? && email =~ /\A[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]+\z/
  end

  def reset_session
    session[:quiz] = nil
    session[:points] = nil
    session[:next_question] = nil
    session[:next_time] = nil
    session[:start_position] = nil
  end

  private
  def require_admin_user
    unless current_user.try(:admin?)
      session[:user_return_to] = request.fullpath
      redirect_to new_user_session_path
    end
  end

  def set_return_url
    session[:user_return_to] = request.fullpath
  end
end
