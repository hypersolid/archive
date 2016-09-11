Quizmaster::Application.configure do
  # Settings specified here will take precedence over those in config/application.rb

  # The test environment is used exclusively to run your application's
  # test suite.  You never need to work with it otherwise.  Remember that
  # your test database is "scratch space" for the test suite and is wiped
  # and recreated between test runs.  Don't rely on the data there!
  config.cache_classes = true

  # Log error messages when you accidentally call methods on nil.
  config.whiny_nils = true

  # Show full error reports and disable caching
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = false

  # Raise exceptions instead of rendering exception templates
  config.action_dispatch.show_exceptions = false

  # Disable request forgery protection in test environment
  config.action_controller.allow_forgery_protection    = false

  # Tell Action Mailer not to deliver emails to the real world.
  # The :test delivery method accumulates sent emails in the
  # ActionMailer::Base.deliveries array.
  config.action_mailer.delivery_method = :test

  # Use SQL instead of Active Record's schema dumper when creating the test database.
  # This is necessary if your schema can't be completely dumped by the schema dumper,
  # like if you have constraints or database-specific column types
  # config.active_record.schema_format = :sql

  # Print deprecation notices to the stderr
  config.active_support.deprecation = :stderr

  config.action_mailer.default_url_options = { :host => 'www.example.com' }
end

# --- Config for Pusher gem ---
Pusher.app_id = '10047'
Pusher.key = '6c89313cf0bb44d25fb4'
Pusher.secret = '7eaf7538232dacc8c099'

# --- Config for Facebook authorization (used in initializers/devise.rb) ---
FACEBOOK =
{
  :app_id => '123464084417935',
  :app_secret => 'b1776cf2a5042ab5abe2ef4e86a82eb6'
}

OmniAuth.config.test_mode = true
OmniAuth.config.mock_auth[:facebook] = {
  :provider => 'facebook',
  :uid => 1206903360,
  :credentials => {:token => "AQBbGOPqhlrlpTwd0a7kTkxdz4IjaCLYa4FICcl7ZGETWS69LAKeZh9I7mvvjNmfik8P_ZIURqkvaIq4cpHiSeEtIgV4ANSsMOyUfkSb1q5kbzL_TMBCtXXXCrN_szDNzDbEfA0V9fMUQWJ3iJR-EttSs8y7WqshTJJmNSlDCXXg6DYcIxHlzPxV7PDkzxe_bpA"},
  :info => {:image => nil},
  :extra => {:raw_info => {:id => 1206903360, :email => "fomichov@gmail.com", :name => "Vitaly"}}
}
