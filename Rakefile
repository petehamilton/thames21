# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require File.expand_path('../config/application', __FILE__)
require 'rake'

# bootstrap the dev environment
require "bundler/setup"
Bundler.require(:test)

EMergency::Application.load_tasks
