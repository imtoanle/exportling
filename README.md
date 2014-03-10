# Exportling

[![Build Status](https://magnum.travis-ci.com/jobready/activebi-rails.png?token=rpAHEL3fvHDpfBeDNS3M&branch=develop)](https://magnum.travis-ci.com/jobready/activebi-rails)
[![Code Climate](https://codeclimate.com/repos/52d855f26956805705008510/badges/ca176e98fe06d57afc9f/gpa.png)](https://codeclimate.com/repos/52d855f26956805705008510/feed)

A simple rails engine for exporting records


## Installation

Add this line to your application's Gemfile:

    gem 'exportling'

And then execute:

    bundle install

Add ActivebiRails to the routes.rb file

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

## Contributing

### Style guidelines

We try to adhere to the following coding style guidelines

  * https://github.com/bbatsov/rails-style-guide
  * https://github.com/bbatsov/ruby-style-guide

### Git Workflow

  * https://github.com/nvie/gitflow
