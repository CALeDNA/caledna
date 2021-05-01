# CALeDNA / Protecting Our River

[![Codeship Status for UCcongenomics/caledna](https://app.codeship.com/projects/9d8e7c50-8a26-0136-e0af-1ac6b3aaffd6/status?branch=master)](https://app.codeship.com/projects/303212)

Rails app the [CALeDNA](http://ucedna.com) and [Protecting Our River](https://www.protectingourriver.org) data portal.

## Tech Stack

- [Ruby 2.6](https://www.ruby-lang.org/en/)
- [Rails 5.2](http://rubyonrails.org)
- [PostgreSQL](https://www.postgresql.org) + [PostGIS](https://postgis.net)
- [Vue.js](https://vuejs.org) for pages that need dyanamic interactions
- [Bootstrap 3.4](https://getbootstrap.com) for styling
- [Administrate](https://github.com/thoughtbot/administrate) for admin dashboard
- [Devise](https://github.com/plataformatec/devise) for authenication
- [Leaflet](http://leafletjs.com) for maps
- [Chart.js](http://chartjs.org), [D3.js](https://d3js.org), [Vega](https://vega.github.io/vega/) for data visualizations
- [Node.js 9](https://nodejs.org/en/) for installing javascript libraries
- [Yarn](https://yarnpkg.com/en/) javascript package manager
- [Webpacker](https://github.com/rails/webpacker) to bundle javascript
- [AWS]
- [Cloudfront]
- [Heroku]
## Setup

Clone this repo.

Install libraries.

```bash
$ bundle install
$ yarn install
```

`rake newb` - runs `setup.rb` to fill out the environmental variables, run
database migrations, and seed the database. Seeding the taxa tables (ncbi_names,
ncbi_nodes) will take many minutes since the taxa tables have over 3.5 GB of
data.

```bash
$ rake newb
```

## Start server

Start rails server.

```bash
$ bin/rails s
```

This app uses Webpacker to handle javascript bundling. Optionally run webpack dev server to live reload javascript changes.

```bash
$ ./bin/webpack-dev-server
```

Optionally run sidekiq to handle background jobs. The most commonly used
background jobs involve importing eDNA results.

```
$ redis-cli flushall
$ bundle exec sidekiq -q default -q mailer
```

## Testing

To run the Rspec tests and Rubocop linter.

```
$ bin/rake
```

## Data Sources

- [KoBo](http://www.kobotoolbox.org) API to import data from the Kobo webforms.
- [NCBI](https://www.ncbi.nlm.nih.gov/taxonomy) for the eDNA taxonomy.
- [GBIF](https://www.gbif.org) API to display occurrence maps on taxa pages and GBIF downloaded dataset for additional occurrence data.
- [GloBI](https://www.globalbioticinteractions.org) for the taxa biological interactions.
- [IUCN]() for the list of threatened / endangered species.

## Notes

### Protecting our River
- The code for the Protecting Our River site are in the `project/pour` branch. Code that can be used on both sites are in `master`. The code only used on PouR are in `project/pour`.
- To incorporate changes from the `master branch` to  `project/pour`, you need switch to `project/pour`, `git rebase master`, and fix any conflicts.

### Squarespace

- The UCeDNA.com site has a Squarespace site for the static content (ucedna.com),
and a Rails app for the data portal (data.ucedna.com).
- The Rails app handles the registration and login. After users login to the Rails app, they are redirected to home page of Squarespace page. On the local development, the login redirects to localhost:9000, which is default port for the Squarespace development server.

### Database

This app uses a lot of sql query and database types that only work on PostgreSQL.

This app uses multiple PostgreSQL database schemas.
- Most of the tables are in `public`.
- The tables that run the Pillar Point research project pages are in `pillar_point`.
- The tables used only for Protecting Our River are in `pour`.
- Tables containing data from GBIF, GloBI, iNaturalist, and 2017 NCBI taxonomy are in `external`.

See `./docs/fall_2020_database_schema.csv` for an explanation of all the tables.

### Update 3rd party data

`bin/rake iunc_data:update_iunc_status` - Connect to IUCN API to update the   `iucn_status` in the `ncbi_nodes` table.

`bin/rake wikidata:<task>` - Query wikidata in order update the taxa links and images from external sites.

`bin/rake gbif:<task>` - Import occcurence and species that are downloaded from GBIF.

