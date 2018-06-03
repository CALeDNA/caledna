# CALeDNA

[ ![Codeship Status for caledna/caledna](https://app.codeship.com/projects/cec73960-e110-0135-f609-6eccc654fb46/status?branch=master)](https://app.codeship.com/projects/266576)

Rails app that handles the data management flow for [CALeDNA](http://ucedna.com).

## Setup

```bash
$ bundle install
$ rake newb
$ yarn
```

## Start server

```bash
$ bin/rails s

# optionally run sidekiq
$ bundle exec sidekiq -q default -q mailer
```

This app uses Webpacker to handle javascript bundling on some pages.

```bash
# optionally run webpack dev server to live reload javascript changes
$ ./bin/webpack-dev-server
```

## Tech Stack

- [Rails 5](http://rubyonrails.org)
- [Vue.js](https://vuejs.org)
- [yarn](https://yarnpkg.com/en/) javascript package manager
- [KoBo](http://www.kobotoolbox.org) to collect field data
- [leaflet](http://leafletjs.com) for the map
- [administrate](https://github.com/thoughtbot/administrate) for the admin dashboard
- [devise](https://github.com/plataformatec/devise) for authenication
- [pundit](https://github.com/varvet/pundit) for authorization
- [webpacker](https://github.com/rails/webpacker) to bundle javascript
- [chart.js](http://chartjs.org) for charts

## Data Sources

We are using [Global Biodiversity Information Facility (GBIF)](http://gbif.org) as
the basis for our taxonomy data.

## Misc

tasks to run when importing data

```bash
# add height and width to photos for photo gallery
rake photos:add_dimensions

# reset counters
rake counter_reset:ncbi_nodes_asvs_count

# import csv that contains geo coordinates for samples
rake sample_coordinates:import
```
