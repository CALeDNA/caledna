# CALeDNA

[ ![Codeship Status for UCcongenomics/caledna](https://app.codeship.com/projects/9d8e7c50-8a26-0136-e0af-1ac6b3aaffd6/status?branch=master)](https://app.codeship.com/projects/303212)

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
$ redis-cli flushall
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

We are using NCBI as the basis for our taxonomy data.

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
