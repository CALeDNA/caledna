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
end
