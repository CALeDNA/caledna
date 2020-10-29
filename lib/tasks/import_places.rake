# frozen_string_literal: true

namespace :import_places do
  require_relative '../../app/services/import_places'
  include ImportPlaces

  IMPORT_GIS_BASE = ENV.fetch('IMPORT_GIS_BASE', '')

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

  task import_la_river: :environment do
    file_path = "#{IMPORT_GIS_BASE}/LA_River_v2_no_mz.shp"
    puts "import #{file_path}"

    import_shapefile(file_path,
                     place_source_type: 'LA_river',
                     place_type: 'river',
                     state_fips: Geospatial::CA_FIPS)
  end

  task import_ucnrs: :environment do
    file_path = "#{IMPORT_GIS_BASE}/nrs_boundaries_final_4326_fix.shp"
    puts "import #{file_path}"

    import_shapefile(file_path,
                     place_source_type: 'UCNRS',
                     place_type: 'UCNRS',
                     state_fips: Geospatial::CA_FIPS)
  end

  task import_ecoregions_l3: :environment do
    file_path = "#{IMPORT_GIS_BASE}/ca_eco_l3.shp"
    puts "import #{file_path}"

    import_shapefile(file_path,
                     place_source_type: 'EPA',
                     place_type: 'ecoregions_l3',
                     state_fips: Geospatial::CA_FIPS)
  end

  task import_ecoregions_l4: :environment do
    file_path = "#{IMPORT_GIS_BASE}/ca_eco_l4.shp"
    puts "import #{file_path}"

    import_shapefile(file_path,
                     place_source_type: 'EPA',
                     place_type: 'ecoregions_l4',
                     state_fips: Geospatial::CA_FIPS)
  end

  task import_la_ecotopes: :environment do
    file_path = "#{IMPORT_GIS_BASE}/2020_LASAN_Ecotopes.shp"
    puts "import #{file_path}"

    import_shapefile(file_path,
                     place_source_type: 'LASAN',
                     place_type: 'ecotopes',
                     state_fips: Geospatial::CA_FIPS,
                     county_fips: Geospatial::LA_COUNTY_FIPS)
  end

  task import_pour_locations: :environment do
    sites = {
      'Arroyo Seco': 'POINT (-118.1664366 34.2036721)',
      'Bull Creek': 'POINT (-118.4977923 34.1830483)',
      'Maywood': 'POINT (-118.1725347 33.9867065)',
      'Compton Creek': 'POINT (-118.2066143 33.8426536)',
      'Long Beach Estuary': 'POINT (-118.2021472 33.7626737)',
      'Glendale Narrows': 'POINT (-118.24225 34.10242)',
      'Elysian Valley': 'POINT (-118.228551 34.08248)',
      'Bowtie Parcel': 'POINT (-118.2479595 34.1093732)',
      'Post-Sepulveda Basin': 'POINT (-118.465969 34.161559)',
      'LA Zoo': 'POINT (-118.28127 34.155683)',
      'Verdugo Wash': 'POINT (-118.237523 34.202886)',
      'Tujunga Wash': 'POINT (-118.389907 34.252641)'
    }

    sites.each do |name, geom|
      matches = /(-[0-9.]+) ([0-9.]+)/.match(geom)
      Place.create(name: name, geom: geom, latitude: matches[2],
                   longitude: matches[1], place_type_cd: 'pour_location',
                   place_source_type_cd: 'LA_river')
    end
  end
end
