module Exportling
  class Engine < ::Rails::Engine
    isolate_namespace Exportling

    # Any gems needed by the engine should be required here (as well as added to the gemspec)
    require 'sidekiq'
    require 'carrierwave'
    require 'fog'
    require 'hash_to_hidden_fields'
    require 'draper'
    require 'hashie'
    require 'hashie_rails'

    # Make sure our query objects are required
    config.to_prepare do
      Dir["#{Exportling::Engine.root}/app/queries/**/*.rb"].each do |query|
        require_dependency(query)
      end
    end

    # Set up the test suite to use rspec and factorygirl
    config.generators do |g|
      g.test_framework      :rspec,        fixture: false
      g.fixture_replacement :factory_girl, dir: 'spec/factories'
      g.assets false
      g.helper false
    end
  end
end
