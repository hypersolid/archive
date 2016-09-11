require "bundler/capistrano"
require "delayed/recipes"  
# require './config/boot'
# require 'airbrake/capistrano'

set :application, "quizmaster"
set :repository,  "git@github.com:newbamboo/quizmaster.git"
set :rails_env, "production"

set :scm, :git
set :deploy_via, :remote_cache
set :deploy_to, "/home/deploy/#{application}"

role :web, "gameshow.co.uk"                          # Your HTTP server, Apache/etc
role :app, "gameshow.co.uk"                          # This may be the same as your `Web` server
role :db,  "gameshow.co.uk", :primary => true # This is where Rails migrations will run
# role :db,  "your slave db-server here"

default_run_options[:pty] = true
set :ssh_options, { :forward_agent => true }

set :user, "deploy"
set :use_sudo, false

# set :branch, "master"
set :branch, $1 if `git branch` =~ /\* (\S+)\s/m

# Delayed Job  
after "deploy:stop",    "delayed_job:stop"  
after "deploy:start",   "delayed_job:start"  
after "deploy:restart", "delayed_job:restart"

# if you're still using the script/reaper helper you will need
# these http://github.com/rails/irs_process_scripts

# If you are using Passenger mod_rails uncomment this:
namespace :deploy do
  task :default do
    update
    migrate
    compass_compile
    restart
    update_crontab
    cleanup
  end

  task :start do ; end
  task :stop do ; end
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
  end
end

desc "remote console"
task :console, :roles => :app do
  input = ''
  run "cd #{current_path} && rails console #{rails_env}" do |channel, stream, data|
    next if data.chomp == input.chomp || data.chomp == ''
    print data
    channel.send_data(input = $stdin.gets) if data =~ /:\d{3}:\d+(\*|>)/
  end
end

desc "remote log"
task :log, :roles => :app do
  run "cd #{current_path} && tail -f log/#{rails_env}.log" do |channel, stream, data|
    print data
  end
end

desc "Update the crontab file"
task :update_crontab, :roles => :app do
  run "cd #{current_path} && whenever --update-crontab #{application} --set environment=#{rails_env}"
end

desc "Compile compass templates"
task :compass_compile, :roles => :app do
  run "cd #{current_path} && bundle exec compass compile public/stylesheets --css-dir . -e #{rails_env} --force --quiet"
end
