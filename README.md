# CALeDNA

[ ![Codeship Status for caledna/caledna](https://app.codeship.com/projects/cec73960-e110-0135-f609-6eccc654fb46/status?branch=master)](https://app.codeship.com/projects/266576)

Rails app that handles the data management flow for [CALeDNA](http://ucedna.com).

## Setup

```
$ bundle install
$ rake newb
```

## Tech Stack

- Rails 5
- [KoBo](http://www.kobotoolbox.org) to collect field data
- [leaflet](http://leafletjs.com) for the map
- [administrate](https://github.com/thoughtbot/administrate) for the admin dashboard
- [devise](https://github.com/plataformatec/devise) for authenication
- [pundit](https://github.com/varvet/pundit) for authorization

## Data Sources

We are using the database from [Itegrated Taxonomic Information System (ITIS)](https://itis.gov) as
the basis for our taxonomy data.
