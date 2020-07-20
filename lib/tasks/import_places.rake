# frozen_string_literal: true

namespace :import_places do
  require_relative '../../app/services/import_places'
  include ImportPlaces

  IMPORT_GIS_BASE = ENV.fetch('IMPORT_GIS_BASE')

  task import_states: :environment do
    file_path = "#{IMPORT_GIS_BASE}/CA_state_TIGER2016.shp"
    puts "import #{file_path}"

    import_shapefile(file_path,
                     place_source_type: 'census',
                     place_type: 'state')
  end

  task import_counties: :environment do
    file_path = "#{IMPORT_GIS_BASE}/CA_Counties_TIGER2016.shp"
    puts "import #{file_path}"

    import_shapefile(file_path,
                     place_source_type: 'census',
                     place_type: 'county')
  end

  task import_ca_places: :environment do
    file_path = "#{IMPORT_GIS_BASE}/CA_Places_TIGER2016.shp"
    puts "import #{file_path}"

    import_shapefile(file_path,
                     place_source_type: 'census',
                     place_type: 'place')
  end

  task import_la_neighborhoods: :environment do
    file_path = "#{IMPORT_GIS_BASE}/LA_Times_neighborhoods.shp"
    puts "import #{file_path}"

    import_shapefile(file_path,
                     place_source_type: 'LA_neighborhood',
                     place_type: 'neighborhood',
                     state_fips: Geospatial::CA_FIPS,
                     county_fips: Geospatial::LA_COUNTY_FIPS)
  end

  task import_la_zip_codes: :environment do
    file_path = "#{IMPORT_GIS_BASE}/LA_County_zipcodes.shp"
    puts "import #{file_path}"

    import_shapefile(file_path,
                     place_source_type: 'LA_zip_code',
                     place_type: 'zip_code',
                     state_fips: Geospatial::CA_FIPS,
                     county_fips: Geospatial::LA_COUNTY_FIPS)
  end

  task import_watersheds: :environment do
    file_path = "#{IMPORT_GIS_BASE}/WBDHU8.shp"
    puts "import #{file_path}"

    import_shapefile(file_path,
                     place_source_type: 'USGS',
                     place_type: 'watershed',
                     state_fips: Geospatial::CA_FIPS)
  end
end
