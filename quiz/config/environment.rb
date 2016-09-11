# Load the rails application
require File.expand_path('../application', __FILE__)

# Initialize the rails application
Quizmaster::Application.initialize!

ActionMailer::Base.smtp_settings = {
  :user_name => "gameshow",
  :password => "hM6qXmo9pDhVCK",
  :domain => "gameshow.com",
  :address => "smtp.sendgrid.net",
  :port => 587,
  :authentication => :plain,
  :enable_starttls_auto => true
}
