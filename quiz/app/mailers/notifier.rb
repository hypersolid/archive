# encoding: utf-8
class Notifier < ActionMailer::Base
  include ActionView::Helpers::NumberHelper
  include ActionView::Helpers::TextHelper
  include ActionView::Helpers::RawOutputHelper
  include ApplicationHelper
  helper :application

  layout 'letters'

  default :from => '"GameShow" <admin@gameshow.co.uk>'
  default :content_type => 'text/html'

  def invite_by_email(relation, message, fallback)
    @relation = relation
    @message = message
    
    @fallback = fallback
    @link = ["Click here to join in!", quiz_quiz_url(:request_id => @relation.request_id)]
    mail(:to => relation.email, :subject => "Invitation to GameShow")
  end

  def wingman_request_accepted(user, wingman, fallback)
    @wingman = wingman
    @user = user
    @fallback = fallback
    @link = ["View ladder", ladders_url]
    mail(:to => @user.email, :subject => "#{@wingman.name} has accepted your wingman request")
  end

  def bonus_credits(user, wingman, fallback)
    @wingman = wingman
    @user = user
    @fallback = fallback
    @link = ["Play now!", new_quiz_url]
    mail(:to => @user.email, :subject => "We've put 2 free credits in your account")
  end

  # when wingman has played his first game
  def has_played_email(wingman, fallback)
    @wingman = wingman 
    @you = @wingman.leader
    @ladder = @you.ladder
    @fallback = fallback
    @time_left = Tournament.current.time_left
    @link = ["Play again now using your free credits", new_quiz_url]
    mail(:to => @you.email, :subject => "#{wingman.name} has played his first game")
  end

  # when you give credits to your wingman
  def nudge_friend_email(user, friend, message, amount, fallback)
    @friend = friend
    @amount = amount
    @message = message
    
    @user = user
    @fallback = fallback
    @link = ["Play game", new_quiz_url]
    mail(:to => @friend.email, :subject => "#{user.name} has sent you #{amount} credit#{'s' if amount != 1}")
  end

  # when you move up the ladder because of your wingman
  def movement(row, ladder, fallback)
    @row = row
    @ladder = ladder 
    @fallback = fallback
    @time_left = Tournament.current.time_left
    @link = ["Improve your score now", new_quiz_url]

    subject = "#{@ladder.user.name} moved you #{@row.up ? 'up' : 'down'} #{pluralize(@row.position_change, "place")} to #{@row.position.ordinalize} position on the ladder"
    mail(:to => @row.user.email, :subject => subject)
  end

  # send notifications when your Facebook friend overtakes you
  def overtaken(row, ladder, fallback)
    @row = row
    @ladder = ladder 
    @fallback = fallback
    @link = ["Play again now", new_quiz_url]

    subject = "#{@ladder.user.name} has overtaken you: you are now #{@row.position.ordinalize}"
    subject << " with " + pounds(@row.prize).sub(/&pound;/, "£") if @row.prize > 0

    mail(:to => @row.user.email, :subject => subject)
  end

  def time_left(ladder, time_left, fallback)
    subject = ""
    subject << pluralize(time_left[:days], "day") if time_left[:days] > 0
    subject << " " + pluralize(time_left[:hours], "hour") if time_left[:hours] > 0
    subject << " left"

    @user = ladder.user
    @fallback = fallback
    @tournament_leader = ladder.tournament.ladders.first.user
    @link = ["View ladder",ladders_url]
    mail(:to => @user.email, :subject => subject)
  end

  def free_credit(ladder, time_left, fallback)
    subject = "You have a free credit - just over a day to go"

    @user = ladder.user
    @fallback = fallback
    @tournament_leader = ladder.tournament.ladders.first.user
    @link = ["View ladder",ladders_url]
    mail(:to => @user.email, :subject => subject)
  end

  # when tournament is over
  def final_summary(ladder, fallback)
    @user = ladder.user
    @fallback = fallback
    mail(:to => @user.email, :subject => "Game Over")
  end

  # when we need more users into the game
  def invite_wingmen(user, fallback)
    @user = user
    @fallback = fallback
    @link = ["Invite wingmen", ladders_url]
    mail(:to => @user.email, :subject => "Invite 2 clever wingmen")
  end

  def wall_message(message, fallback)
    @message = message
    @fallback = fallback
    @link = ["View it now", ladders_url]
    mail(:to => @message.recipient.email, :subject => "#{@message.sender.name} wrote on your wall")
  end

  # send admin notification
  def payment(payment, fallback)
    @fallback = fallback
    @payment = payment

    mail(:to => "jamie@glassesdirect.co.uk", :subject => "Got new payment") 
  end
end