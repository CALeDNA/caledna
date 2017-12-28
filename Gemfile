# frozen_string_literal: true

source 'https://rubygems.org'

ruby '2.4.0'
gem 'rails', '~> 5.0.1'

gem 'administrate'
gem 'airbrake', require: false
gem 'autoprefixer-rails'
gem 'bundler'
gem 'coffee-rails'
gem 'devise'
gem 'flutie'
gem 'i18n-tasks'
gem 'newrelic_rpm'
gem 'pg'
gem 'puma'
gem 'rack-canonical-host'
gem 'recipient_interceptor'
gem 'sass-rails'
gem 'sidekiq'
gem 'simple_form'
gem 'title'
gem 'turbolinks'
gem 'uglifier'

source 'https://rails-assets.org' do
  gem 'rails-assets-jquery'
  gem 'rails-assets-jquery-ujs'
end

group :development do
  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'spring'
  gem 'spring-commands-rspec'
  gem 'stairs'
end

group :development, :test do
  gem 'bundler-audit', require: false
  gem 'dotenv-rails'
  gem 'factory_girl_rails'
  gem 'listen'
  gem 'pry-byebug'
  gem 'pry-rails'
  gem 'rspec-rails'
  gem 'rubocop'
end

group :test do
  # gem "capybara-webkit"
  gem 'database_cleaner'
  gem 'launchy'
  gem 'rspec-sidekiq'
  gem 'shoulda-matchers', require: false
  gem 'timecop'
end
