source 'https://rubygems.org'

def darwin_only(require_as)
  RUBY_PLATFORM.include?('darwin') && require_as
end

def linux_only(require_as)
  RUBY_PLATFORM.include?('linux') && require_as
end

gem 'rails', '3.2.12'

# DB
gem 'mysql2', group: :mysql
gem 'pg',     group: :postgres

# Settings
gem 'settingslogic'

# Auth
gem 'devise'
gem 'omniauth', "~> 1.1.3"

# LDAP Auth
gem 'gitlab_omniauth-ldap', '1.0.2', require: "omniauth-ldap"

# Web server
gem 'thin'
gem "unicorn", "~> 4.4.0"

# Haml
gem 'haml-rails'

# Background jobs
gem 'slim'
gem 'sinatra', :require => nil
gem 'sidekiq', '2.6.4'

# Scheduled
gem 'whenever', require: false

# Format dates
gem 'stamp'

# Git support
gem 'grit'

# Pagination
gem 'kaminari'

# State machine
gem 'state_machine'

# Encoding detection
gem 'charlock_holmes'

# Other
gem 'rake'
gem 'foreman'
gem 'jquery-rails'
gem 'childprocess'
gem 'gitlab_ci_meta'

group :assets do
  gem 'sass-rails',   '~> 3.2.3'
  gem 'coffee-rails', '~> 3.2.1'

  gem 'uglifier', '>= 1.0.3'
  gem "therubyracer"
  gem 'bootstrap-sass'
end


group :development do
  gem 'annotate'
  gem 'quiet_assets'
end


group :development, :test do
  gem 'pry'
  gem 'rspec-rails'
  gem 'capybara'
  gem 'factory_girl_rails'
  gem "ffaker"

  gem 'shoulda-matchers'
  gem 'guard-rspec'
  gem 'rb-fsevent', require: darwin_only('rb-fsevent')
  gem 'growl',      require: darwin_only('growl')
  gem 'rb-inotify', require: linux_only('rb-inotify')

  gem 'coveralls', require: false
end

# API
gem "grape", "~> 0.3.1"
gem "grape-entity", "~> 0.2.0"

# Git clone
gem "gitlab-grit", '~> 1.0.0', require: 'grit'
