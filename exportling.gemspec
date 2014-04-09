$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "exportling/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "exportling"
  s.version     = Exportling::VERSION
  s.authors     = ["John D'Agostino"]
  s.email       = ["john.dagostino@gmail.com"]
  s.homepage    = "http://github.com/johndagostino/exportling"
  s.summary     = "Rails record exporting engine"
  s.description = "A simple rails engine for exporting records"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["spec/**/*"]

  s.add_dependency "rails", "~> 4.0"
  # TODO: Version dependencies
  s.add_dependency 'carrierwave'
  s.add_dependency 'sidekiq'
  s.add_dependency 'hash_to_hidden_fields'
  s.add_dependency 'draper'

  s.add_development_dependency "rspec-rails", '~> 3.0.0.beta'
  s.add_development_dependency 'factory_girl_rails'
  s.add_development_dependency 'database_cleaner'
  s.add_development_dependency "byebug"
  s.add_development_dependency "sqlite3"
end
