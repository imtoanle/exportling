$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "exportling/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "exportling"
  s.version     = Exportling::VERSION
  s.authors     = ["John D'Agostino", 'David Reece']
  s.email       = ["john.dagostino@gmail.com", 'dv.reece@gmail.com']
  s.homepage    = "http://github.com/jobready/exportling"
  s.summary     = "Rails record exporting engine"
  s.description = "A simple rails engine for exporting records"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["spec/**/*"]

  s.add_dependency "rails", ">= 4.0", "< 5.1"
  s.add_dependency 'carrierwave', '~> 0.10.0'
  s.add_dependency 'carrierwave-aws'
  s.add_dependency 'sidekiq', '>= 2.17.0'
  s.add_dependency 'kaminari', '~> 0.16'
  s.add_dependency 'hash_to_hidden_fields', '~> 2.0.1'
  s.add_dependency 'draper', '>= 2.1.0'
  s.add_dependency 'ransack'
  s.add_dependency 'strata', '~> 0.6'

  s.add_development_dependency "rspec-rails", '~> 3.5.2'
  s.add_development_dependency 'factory_girl_rails', '~> 4.4.1'
  s.add_development_dependency 'database_cleaner', '~> 1.2.0'
  s.add_development_dependency "byebug", '~> 2.7.0'
  s.add_development_dependency "sqlite3"
  s.add_development_dependency 'sinatra', '~> 1.3.0'
  s.add_development_dependency 'rails-controller-testing'
  s.add_development_dependency 'codeclimate-test-reporter'
  s.add_development_dependency 'simplecov'
end
