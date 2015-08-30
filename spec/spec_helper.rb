if ENV['SIMPLECOV']
  require 'simplecov'
  SimpleCov.start
end

if ENV['COVERALLS']
  require 'coveralls'
  Coveralls.wear!('rails')
end

ENV["RAILS_ENV"] ||= 'test'

require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'
require 'shoulda/matchers'
require 'sidekiq/testing/inline'

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[Rails.root.join("spec/support/**/*.rb")].each {|f| require f}

RSpec.configure do |config|
  config.use_transactional_fixtures = false
  config.use_instantiated_fixtures  = false
  config.mock_with :rspec

  config.include LoginHelpers, type: :feature
  config.include LoginHelpers, type: :request
  config.include StubGitlabCalls
  config.include StubGitlabData

  config.infer_spec_type_from_file_location!
  config.raise_errors_for_deprecations!
end

ActiveRecord::Migration.maintain_test_schema!
