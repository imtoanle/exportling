# Exportling

[![Build Status](https://magnum.travis-ci.com/jobready/activebi-rails.png?token=rpAHEL3fvHDpfBeDNS3M&branch=develop)](https://magnum.travis-ci.com/jobready/activebi-rails)
[![Code Climate](https://codeclimate.com/repos/52d855f26956805705008510/badges/ca176e98fe06d57afc9f/gpa.png)](https://codeclimate.com/repos/52d855f26956805705008510/feed)

A simple rails engine for exporting records


## Installation

Add this line to your application's Gemfile:

    gem 'exportling'

And then execute:

    bundle install

Add Exportling to the routes.rb file

    mount Exportling::Engine, at: '/exports'

Generate migrations

    bundle exec rake exportling:install:migrations

Run migrations

    bundle exec rake db:migrate

Add assets

`app/assets/javascripts/application.js`

    //= require exportling/exportling

`app/assets/stylesheets/application.scss`

    *= require exportling/exportling


Configure Exportling in your application

`config/initializers/exportling.rb`

    # (Recommended) Set the export owner class (used to scope exports to a parent)
    Exportling.export_owner_class = "User"
    
    # (Optional) Set the export save directory ('exportling' by default)
    # All files will be saved under custom_exportling_directory/exports/owner_id/
    Exportling.base_storage_directory = 'custom_exportling_directory'



## Current State
Exportling currently allows a developer to specify a single model to be exported. No nesting/associations are available yet, exports are performed when requested (not by a background worker), and no download link is available for the export.

The exports are stored under `tmp/exports`.

## Usage
To export a model, you will need to define two classes

### Query
The query object is used to pull the model information from the database. This should look like the following:

    class HouseExporterQuery < Exportling::ExporterQuery
      # Need to define this to set the default relation. The exporter does not pass a relation to the query, so the constructor should define it by default
      def initialize(options, relation = House.all)
        @options  = options
        @relation = relation
      end

      # query_options will be passed to a find_each, so should match whatever the `export's` params are for this model.
      # e.g. If @export.params => { house: { furnished: false } }, you want to return the value of the :house key.
      def query_options
        @options.try(:[], :house)
      end
    end


### Exporter
The exporter class is responsible for defining the fields to be exported, the query object to fetch the data, and the handling of the actual data export. When the export starts, the `on_start` method is called. Similarly, the `on_finish` method is called at the end of the export. Finally, for each item found, `on_entry` is called, with the model data passed as an argument.

    class HouseCsvExporter < Exportling::Exporter
      # Specify the fields we want in the final export
      export_field :id
      export_field :price
      export_field :square_meters

      # Specify the query object that should be used to retrieve the model data
      query_class HouseExporterQuery

      # Called at the start of parent perform
      # Open a new csv file, and add field headers
      def on_start
        csv_file_name = "#{Rails.root}/tmp/exports/#{@export.file_name}"
        @csv = CSV.open(csv_file_name, 'wb')
        @csv << field_names
      end

      # Called for each entry of parent perform
      def on_entry(export_data)
        @csv << export_data.attributes.values_at(*field_names)
      end

      # Called at end of parent perform
      # Write the CSV to file
      def on_finish
        @csv.close_write
      end
    end



## Contributing

### Specs
Unit tests are performed using rspec. To prepare your environment to run specs, you will need to prepare your test database.

From the base engine directory, run the following:

    bundle exec rake app:db:migrate
    bundle exec rake app:db:test:prepare


After migrations have been run, specs can be run from the base engine directory with `bundle exec rspec spec`.


### Style guidelines

We try to adhere to the following coding style guidelines

  * https://github.com/bbatsov/rails-style-guide
  * https://github.com/bbatsov/ruby-style-guide

### Git Workflow

  * https://github.com/nvie/gitflow
