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

  task import_pillar_point_gbif_sources: :environment do
    puts 'import pillar point gbif sources'

    project_id = ResearchProject.find_by(name: 'Pillar Point').id

    locations = {
      embankment_unprotected: {
        file: 'PillarPoint_embankment_unprotected_GBIF_noCLO.txt',
        location: 'Pillar Point embankment unprotected'
      },
      exposed_unprotected: {
        file: 'PillarPoint_exposed_unprotected_GBIFnoCLO.txt',
        location: 'Pillar Point exposed unprotected'
      },
      SMCA: {
        file: 'PillarPointSMCA_GBIFnoCLO.txt',
        location: 'Pillar Point SMCA'
      },
      Montara_SMR: {
        file: 'Montara_SMR_GBIFnoCLO.txt',
        location: 'Montara SMR'
      }
    }

    # rubocop:disable Metrics/MethodLength
    def create_source(location, project_id)
      GbifOccurrence.all.each do |obs|
        source = ResearchProjectSource.find_by(
          sourceable_id: obs.gbifid, sourceable_type: 'GbifOccurrence'
        )

        next if source.present?
        attributes = {
          research_project_id: project_id,
          sourceable_id: obs.gbifid,
          sourceable_type: 'GbifOccurrence',
          metadata: { location: location }
        }
        ResearchProjectSource.create(attributes)
      end
    end
    # rubocop:enable Metrics/MethodLength

    def import_csv(path)
      CSV.foreach(path, headers: true, col_sep: "\t") do |row|
        obs = GbifOccurrence.find_by(gbifid: row['gbifid'])

        attributes = row.to_hash
        attributes['classname'] = attributes['class']
        attributes.delete('class')
        GbifOccurrence.create(attributes) if obs.nil?
      end
    end

    locations.keys.each do |key|
      location = locations[key][:location]
      path = "#{Rails.root}/db/data/private/gbif/#{locations[key][:file]}"
      puts location

      puts 'import csv...'
      import_csv(path)

      puts 'create sources...'
      create_source(location, project_id)
    end
  end
end
