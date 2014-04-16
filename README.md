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

Exportling currently allows a developer to specify a simple nested exports. Exports are processed in the foreground, not by a background worker.

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
The exporter class is responsible for defining the fields to be exported, the query object to fetch the data, and the handling of the actual data export. When the export starts, the `on_start` method is called. Similarly, the `on_finish` method is called at the end of the export. Finally, for each item found, `on_entry` is called, with the model and associated data passed as an argument.

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
      # Export data is a single object of the type that this is exporting (House, in this case).
      def on_entry(export_data, associated_data)
        @csv << export_data.attributes.values_at(*field_names)
      end

      # Called at end of parent perform
      # Write the CSV to file
      def on_finish
        @csv.close_write
      end
    end

#### Associations
Any exporter can specify associations. These are (usually) models that are associated with the model being exported, and will often be scoped to that object.

##### <a name="specifying"></a>Specifying an Association
Associations are specified on an exporter by using `export_association`. This expects a hash of one key:value pair. The key is not restricted to the correct association name, and may be called anything. The data returned from the specified exporter will be under the same key as it is defined here (`:rooms` in the below example).

    class HouseCsvExporter < Exportling::Exporter
        export_association rooms: {
          exporter_class: RoomExporter,
          params:         { room: { house_id: :id } }
        }
    end

This means that for each entry (instance of `House` in this case) found, a RoomExporter will be instantiated and performed with the addition of the params specified.

##### Parent Context
Whenever child data is fetched from an associated exporter, the params specified via `export_association` are passed to the child. This means we can specify query params for the child in 3 separate ways.

###### Export Instance
Any params saved to the export will be passed to the query object of each exporter. These params are generally set in the initial export form, and are used to (for example) set query params based on a currently set filter (e.g. only rooms with names in 'Bedroom', 'Bathroom').

The params saved in the export instance have a lower precedence than those specified on the association. In the event of a conflict, the association params (below) will override the export params.

###### Static Association Params
A less common case, the `export_association` can be used to set static params at definition time. To use the example above, we could make only ever fetching rooms with names of 'Bedroom' or 'Bathroom' the default behaviour for this associated export.

    class HouseCsvExporter < Exportling::Exporter
        export_association rooms: {
          exporter_class: RoomExporter,
          params:         { room: { name: ['Bedroom', 'Bathroom'] } }
        }
    end

Note that these params aren't particularly useful, as *every* room that meets these conditions will be fetched for *every* house, not just the rooms for the current house. To limit the rooms to those that belong to the current house, see below.

###### Dynamic Association Params
Probably the most common case, as this allows us to scope the child export to the current parent object. For example, if we want to fetch all rooms of our current house for each house entry, we would specify our association params as below.

    params: { room: { house_id: :id } }
    
Notice that the value for `house_id` is the placeholder symbol, `:id`. Before passing the params to the associated exporter, exportling will attempt to replace any symbols with data for the current entry. If the entry responds to the symbol, the symbol will be replaced with real data. Otherwise, an error is raised.

The entry is whatever is passed back from the query object of the current exporter. In the case of the `HouseCsvExporter`, this is a `House` instance. However, there are no restrictions in the system preventing the query object from returning any arbitrary object. As long as the object responds to any symbol value defined in the association params, exportling will replace the symbol with the returned method value.


#### Example Exports
##### Concatinated Child Data

If we have a `House` that `has_many :rooms`, and we wish to create a CSV export that lists each house, with a pipe delimited list of room names for each house entry, we have a couple of ways we can achieve this.


Example Line:

    id, price,   size, room_names
    32, 350_000, 600,  Living|Lounge|Bed1|Bed2

Common to both approaches is the requirement that we define the room association on the HouseCSVExporter. Assuming the rest of the exporter shown above remains the same, the association is defined as per the example in [Specifying an Association](#specifying).

Finally, to actually fetch the room data, we need to create exporter and query objects for `Room`. The query object will be the same, regardless of exporter created, and will be defined as shown.

    class RoomExporterQuery < Exportling::ExporterQuery
      def initialize(options, relation = Room.all)
        @options  = options
        @relation = relation
      end

      # Which of the provided params do we use to find the appropriate records
      def query_options
        @options.try(:[], :room)
      end
    end

###### Approach 1 - Minimal Room Exporter
Creating the most basic room exporter will allow us to create the CSV we want by offloading some of the complexity of the export to the parent (`House`) exporter.

    class RoomExporter < Exportling::Exporter
      export_field :id
      export_field :name
      export_field :house_id

      query_class RoomExporterQuery

      def on_start(temp_file=nil)
      end

      def on_entry(export_data, associated_data=nil)
      end

      def on_finish
      end
    end

If this exporter is used on its own, it will not write anything to an export file, as none of its callback methods are actually processing the data. However, its default behaviour means it will at least store all found entries in an accessable instance variable.

The default exporter behaviour saves each entry in the exporter's `export_entries` instance variable. Because the `HouseCsvExporter` has defined this as an association, `export_entries` will be passed to the house exporter's `on_entry` method as the second argument. To create the example csv line described above, the `HouseCsvExporter` needs to change its `on_entry` method to the following:
    
      def on_entry(export_data, associated_data=nil)
        # Data from this house
        row_data = export_data.attributes.values_at(*field_names)
        # Data from child rooms of this house
        row_data << associated_data[:rooms].map(&:name).join('|') unless associated_data.nil?
        # Write to memory/file
        @csv << row_data
      end

Note that `associated_data` will be returned as a hash, with the data returned by the associated exporter under the key used to define the associated export (`export_association :rooms => { ... }`).

###### Approach 2 - Custom Room Exporter
As the exporter is responsible for fetching data, it can store it in such a way that it is easier to use by a parent exporter. For example, if this `RoomExporter` is only used as an associated exporter of the `HouseCsvExporter`, we know that the parent only wants a pipe delimited list of room names.

To provide this, the `RoomExporter` needs to overwrite the `save_entry` method. As with `on_entry`, this method is called for each entry found by the exporter. Unlike `on_entry`, `save_entry` is not an abstract method, and so provides default behaviour. By default, `save_entry` just builds an array of entries, and is defined as:

    def save_entry(export_data, associated_data=nil)
      @export_entries ||= []
      @export_entries << export_data
    end

The `RoomExporter` could overwrite this method to become:

    def save_entry(export_data, associated_data=nil)
      @export_entries ||= []
      @export_entries << export_data.name
    end
    
This reduces the data we are storing and returning, but still requires the processing by the parent exporter. Rather than passing back the array of names, we could pass back the concatenated string by overwriting the `export_entries` method, which just returns `@export_entries` by default.

    def export_entries
      @export_entries.join('|')
    end

With these changes to the `RoomExporter`, we can change the `HouseCsvExporter`'s `on_entry` to the following:

    def on_entry(export_data, associated_data = nil)
      row_data = export_data.attributes.values_at(*field_names)
      row_data << associated_data[:rooms] unless associated_data.nil?
      @csv << row_data
    end


##### Left Outer Join

Example Lines

    id, price,   size, room_name
    32, 350_000, 600,  Living
    32, 350_000, 600,  Lounge
    32, 350_000, 600,  Bed1
    32, 350_000, 600,  Bed2

    
If you are looking to export data as would be returned from a LEFT OUTER JOIN query (as shown above), you would set up your exporters as below.

###### Room Exporter
Define this exporter as the most basic possible

    class RoomExporter < Exportling::Exporter
      export_field :id
      export_field :name
      export_field :house_id

      query_class RoomExporterQuery

      def on_start(temp_file=nil)
      end

      def on_entry(export_data, associated_data=nil)
      end

      def on_finish
      end
    end

Alternatively, as only names are needed in the export, you could overwrite `save_entry` to only save room names, rather than model data for the entire room.

###### House Exporter
This is defined as before, with the only change made to `on_entry`.

      def on_entry(export_data, associated_data=nil)
        row_data = export_data.attributes.values_at(*field_names)
        # Data from child rooms of this house
        if associated_data.present?
          associated_data[:rooms].each do |room_entry|
            @csv << (row_data + [room_entry.name])
          end
        else
          @csv << row_data          
        end
      end

##### Room Data Grouped Under House Entry
This kind of export doesn't make sense as a CSV export, but could be used in (for example) PDF and XML exports.

As above, the room exporter is defined as a minimal exporter (potentially overwriting `save_entry` to save the minimum required data, or alter it before it is passed back to the parent).

Again this behaviour is made possible by altering the `HouseCsvExporter`'s `on_entry`. Assuming you have defined `write_entry` and `write_child_entry` methods.

      def on_entry(export_data, associated_data=nil)
        house_data = export_data.attributes.values_at(*field_names)
       	write_entry(house_data)
        
        # Data from child rooms of this house
        if associated_data.present?
          associated_data[:rooms].each do |room_entry|
            write_child_entry(room_entry)
          end
        end
      end


### Form
To allow the user to request an export, you need to create a form to send export information to to the export engine. Assuming you have exportling mounted as `:export_engine`, and wish to export a single `House` object. 

    <%= form_tag("#{export_engine.exports_path}/new", method: :get) do -%>
      <!-- The exporter class that will be the entry point of the export -->
      <%= hidden_field_tag :klass, 'HouseExporter' %>
      <!-- FIXME: This is super insecure. Actual owner should be set in controller -->
      <%= hidden_field_tag :owner_id, user.id %>
      <!-- All params sent will be saved in the export object, and used by the exporters to find objects to export -->
      <%= hidden_field_tag 'params[house][id]', [house.id] %>
      <!-- NOTE: File Type is not currently used by the exporter, and will probably be removed (required for now) -->
      <%= hidden_field_tag :file_type, 'csv' %>
      <!-- NOTE: Method is not currently used by the exporter, and will probably be removed (required for now) -->
      <%= hidden_field_tag :method, 'TODO' %>
      <%= submit_tag 'Export CSV' %>
    <% end -%>

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
