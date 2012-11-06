source 'https://rubygems.org'

def darwin_only(require_as)
  RUBY_PLATFORM.include?('darwin') && require_as
end

def linux_only(require_as)
  RUBY_PLATFORM.include?('linux') && require_as
end

gem 'rails', '3.2.8'

# DB
gem 'mysql2'

# Settings
gem 'settingslogic'

# Auth
gem 'devise'

# Web server
gem 'thin'

# Haml
gem 'haml-rails'

# Jobs
gem 'resque'

# Format dates
gem 'stamp'

# Pagination
gem 'will_paginate', '~> 3.0'

# Other
gem 'rake'
gem 'foreman'
gem 'jquery-rails'
gem 'childprocess'

group :assets do
  gem 'sass-rails',   '~> 3.2.3'
  gem 'coffee-rails', '~> 3.2.1'

  gem 'uglifier', '>= 1.0.3'
  gem "therubyracer"
  gem 'bootstrap-sass'
end


group :development do
  gem 'annotate'
end


group :development, :test do
  gem 'pry'
  gem 'rspec-rails'
  gem 'capybara'

  gem 'shoulda-matchers'
  gem 'guard-rspec'
  gem 'rb-fsevent', require: darwin_only('rb-fsevent')
  gem 'growl',      require: darwin_only('growl')
  gem 'rb-inotify', require: linux_only('rb-inotify')
end
