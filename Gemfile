# frozen_string_literal: true

source 'https://rubygems.org'

ruby '2.4.0'
gem 'rails', '~> 5.0'

# using branch of administrate because it hasn't been merged into master yet
gem 'administrate', git: 'git://github.com/jonatasrancan/administrate.git',
                    branch: 'feature/search-through-association-fields'
gem 'administrate-field-json', '~> 0.0.4'
gem 'airbrake', '~> 7.1', require: false
gem 'autoprefixer-rails', '~> 7.2'
gem 'bootstrap-sass', '~> 3.3.7'
gem 'bundler'
gem 'coffee-rails', '~> 4.2'
gem 'devise', '~> 4.3'
gem 'devise_invitable', '~> 1.7.0'
gem 'flutie', '~> 2.0'
gem 'httparty', '~> 0.15.6'
gem 'i18n-tasks', '~> 0.9'
gem 'jquery-rails', '~> 4.3.1'
gem 'kaminari', '~> 1.1.1'
gem 'newrelic_rpm', '~> 4.7'
gem 'pg', '~> 0.21'
gem 'pundit', '~> 1.1.0' # added pundit to deal with administrate bug
# https://github.com/thoughtbot/administrate/issues/1048
gem 'puma', '~> 3.11'
gem 'rack-canonical-host', '~> 0.2'
gem 'recipient_interceptor', '~> 0.1'
gem 'sass-rails', '~> 5.0'
gem 'sidekiq', '~> 5.0'
gem 'simple_form', '~> 3.5'
gem 'title', '~> 0.0'
gem 'turbolinks', '~> 5.0'
gem 'uglifier', '~> 4.0'

source 'https://rails-assets.org' do
  gem 'rails-assets-jquery', '~> 3.2'
  gem 'rails-assets-jquery-ujs', '~> 1.2'
end

group :development do
  gem 'better_errors', '~> 2.4'
  gem 'binding_of_caller', '~> 0.7'
  gem 'letter_opener', '~> 1.4.1'
  gem 'spring', '~> 2.0'
  gem 'spring-commands-rspec', '~> 1.0'
  gem 'stairs', '~> 0.10'
end

group :development, :test do
  gem 'bundler-audit', '~> 0.6', require: false
  gem 'dotenv-rails', '~> 2.2'
  gem 'factory_bot_rails', '~> 4.8.2'
  gem 'faker', '~> 1.8.7'
  gem 'listen', '~> 3.1'
  gem 'pry-byebug', '~> 3.5'
  gem 'pry-rails', '~> 0.3'
  gem 'rspec-rails', '~> 3.7'
  gem 'rubocop', '~> 0.52'
end

group :test do
  gem 'capybara-webkit', '~> 1.14'
  gem 'database_cleaner', '~> 1.6'
  gem 'launchy', '~> 2.4'
  gem 'rails-controller-testing', '~> 1.0.2'
  gem 'rspec-sidekiq', '~> 3.0'
  gem 'shoulda-matchers', '~> 3.1', require: false
  gem 'timecop', '~> 0.9'
end
