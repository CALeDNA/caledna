# frozen_string_literal: true

# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be
# available to Rake.

require_relative 'config/application'

Rails.application.load_tasks
task(:default).clear

if defined?(RSpec) && defined?(RuboCop)
  require 'rubocop/rake_task'
  require 'rspec/core/rake_task'

  RuboCop::RakeTask.new

  task default: %i[spec rubocop]
end
