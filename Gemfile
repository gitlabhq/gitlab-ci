source 'https://rubygems.org'

def darwin_only(require_as)
  RUBY_PLATFORM.include?('darwin') && require_as
end

def linux_only(require_as)
  RUBY_PLATFORM.include?('linux') && require_as
end

gem 'rails', '3.2.14'

# DB
gem 'mysql2', group: :mysql
gem 'pg',     group: :postgres

# Settings
gem 'settingslogic'

# Web server
gem "puma", "~> 2.3.2"

# Haml
gem 'haml-rails'

# Background jobs
gem 'slim'
gem 'sinatra', :require => nil
gem 'sidekiq'

# Scheduled
gem 'whenever', require: false

# Format dates
gem 'stamp'

# Pagination
gem 'kaminari'

# State machine
gem 'state_machine'

# For API calls
gem 'httparty', '0.11.0'

# API
gem 'grape'
gem 'grape-entity'

# Other
gem 'rake'
gem 'foreman'
gem 'jquery-rails'
gem 'gitlab_ci_meta'

group :assets do
  gem 'sass-rails',   '~> 3.2.3'
  gem 'coffee-rails', '~> 3.2.1'

  gem 'uglifier', '>= 1.0.3'
  gem "therubyracer"
  gem 'bootstrap-sass'
  gem "font-awesome-sass-rails"
end


group :development do
  gem 'annotate'
  gem 'quiet_assets'
end


group :development, :test do
  gem 'pry'
  gem 'rspec-rails'
  gem 'capybara'
  gem 'poltergeist'
  gem 'factory_girl_rails'
  gem "ffaker"

  gem 'shoulda-matchers'
  gem 'guard-rspec'
  gem 'rb-fsevent', require: darwin_only('rb-fsevent')
  gem 'growl',      require: darwin_only('growl')
  gem 'rb-inotify', require: linux_only('rb-inotify')

  gem "simplecov", require: false
  gem 'coveralls', require: false
  gem 'minitest', '4.3.2'
end
