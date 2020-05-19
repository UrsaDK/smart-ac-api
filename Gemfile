# frozen_string_literal: true

source 'https://rubygems.org'

gem 'rake'
gem 'sequel'
gem 'sinatra'
gem 'sinatra-contrib'
gem 'sqlite3'

# bundle --without development
group :development do
  gem 'pry', require: true              # An alternative IRB console
  gem 'pry-bond', require: false        # Input completion in pry console
  gem 'pry-byebug', require: false      # Adds step, next, continue & break
  gem 'pry-highlight', require: false   # Highlight and prettify console output
  gem 'pry-remote', require: true       # Use Pry remotely: binding.remote_pry
end

# bundle --without tests
group :tests do
  gem 'rspec', require: false           # Test driven development
  gem 'rubocop', require: false         # Static code analyzer
  gem 'rubocop-rspec', require: false   # Rubocop checker for rspec
  gem 'simplecov', require: false       # Code coverage report generator
end
