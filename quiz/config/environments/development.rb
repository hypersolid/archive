Quizmaster::Application.configure do
  # Settings specified here will take precedence over those in config/application.rb

  # In the development environment your application's code is reloaded on
  # every request.  This slows down response time but is perfect for development
  # since you don't have to restart the webserver when you make code changes.
  config.cache_classes = false

  # Log error messages when you accidentally call methods on nil.
  config.whiny_nils = true

  # Show full error reports and disable caching
  config.consider_all_requests_local       = true
  # config.action_view.debug_rjs             = true
  config.action_controller.perform_caching = false

  # Don't care if the mailer can't send
  config.action_mailer.raise_delivery_errors = false

  # Print deprecation notices to the Rails logger
  config.active_support.deprecation = :log

  # Only use best-standards-support built into browsers
  config.action_dispatch.best_standards_support = :builtin

  #config.action_mailer.default_url_options = { :host => 'quizmaster.dev' }
  config.action_mailer.default_url_options = { :host => 'localhost:3000' }
end

# --- Config for Pusher gem ---
Pusher.app_id = '10047'
Pusher.key = '6c89313cf0bb44d25fb4'
Pusher.secret = '7eaf7538232dacc8c099'
#LADDER_CHANNEL = 'ladder-development' # the Pusher channel name for the Ladder page

# --- Config for Facebook authorization (used in initializers/devise.rb) ---
FACEBOOK =
{
  # quizmaster.dev
  :app_id => '123464084417935',
  :app_secret => 'b1776cf2a5042ab5abe2ef4e86a82eb6'

  # localhost:3000
  #:app_id => '205066922866699',
  #:app_secret => '9fad9a2046d088580e7cd053e3e00cdf'
}

Paperclip.options[:command_path] = "/usr/bin/"

