# frozen_string_literal: true

namespace :research_project do
  require 'csv'

  task import_pillar_point_sources: :environment do
    path = "#{Rails.root}/db/data/private/pillar_point_sources.csv"

    puts 'import pillar point sources'

    project_id = ResearchProject.find_by(name: 'Pillar Point').id

    CSV.foreach(path, headers: true) do |row|
      attributes = {
        research_project_id: project_id,
        sourceable_id: row['id'].to_i,
        sourceable_type: 'InatObservation'
      }
      ResearchProjectSource.create(attributes)
    end
  end

  task import_pillar_point_samples: :environment do
    path = "#{Rails.root}/db/data/private/pillarpoint_metadata.csv"

    puts 'import pillar point samples'

    CSV.foreach(path, headers: true) do |row|
      barcode = row['sum.taxonomy']
      next if barcode.blank?

      puts barcode

      attributes = {
        latitude: row['Latititude'],
        longitude: row['Longitude'],
        gps_precision: row['Accuracy'],
        metadata: {
          habitat_type: row['Habitat_type'],
          zone: row['Zone'],
          protected: row['Protected (Y/N)'],
          median_tide_line: row['Median Tide Line'],
          location_in_harbor: row['Location in Harbor'],
          sand_type: row['Sand_type'],
          note: row['Note']
        }
      }
      sample = Sample.find_by(barcode: barcode)
      sample.update(attributes)
    end
  end
end
