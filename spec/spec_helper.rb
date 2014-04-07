ENV['RAILS_ENV'] ||= 'test'
require File.expand_path("../dummy/config/environment.rb",  __FILE__)
require 'rspec/rails'
require 'factory_girl_rails'
require 'byebug'

Rails.backtrace_cleaner.remove_silencers!

# Load support files
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |f| require f }

RSpec.configure do |config|
  config.mock_with :rspec
  config.use_transactional_fixtures = true
  config.infer_base_class_for_anonymous_controllers = false
  config.order = "random"

  # Pretty up rspec output somewhat
  config.color_enabled = true
  config.formatter = :documentation

  # Make sure we fail the build for deprecation warnings (which will give us a proper backtract)
  config.raise_errors_for_deprecations!
end
