require 'simplecov'
SimpleCov.start

SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter[
  SimpleCov::Formatter::HTMLFormatter
]

ENV['RAILS_ENV'] ||= 'test'
require File.expand_path("../dummy/config/environment.rb",  __FILE__)

# Require any gems needed for the spec suite
require 'rspec/rails'
require 'factory_girl_rails'
require 'byebug'
require 'database_cleaner'
require 'sidekiq/testing'

Rails.backtrace_cleaner.remove_silencers!

# Load support files
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |f| require f }

RSpec.configure do |config|
  config.mock_with :rspec
  config.use_transactional_fixtures = true
  config.infer_base_class_for_anonymous_controllers = false
  config.order = "random"

  # Pretty up rspec output somewhat
  config.color = true
  config.formatter = :documentation

  # Make sure we clear Sidekiq jobs between tests
  config.before(:each) do
    Sidekiq::Worker.clear_all
  end

  # Make sure we fail the build for deprecation warnings (which will give us a proper backtrace)
  config.raise_errors_for_deprecations!
end
