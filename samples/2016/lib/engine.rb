require 'pry-rails'
require 'pry-byebug'
require 'colorize'

module GUtils
  class Engine < ::Rails::Engine
    config.autoload_paths << "#{root}/lib"
  end
end
