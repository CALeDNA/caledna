# frozen_string_literal: true

namespace :research_project_pillar_point do
  require 'csv'

  task create_project_sources_for_inat: :environment do
    path = "#{Rails.root}/db/data/private/pillar_point_sources.csv"

    puts 'import inat...'

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

  task import_samples_metadata: :environment do
    path = "#{Rails.root}/db/data/private/pillarpoint_metadata.csv"

    puts 'import samples metadata...'

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
          note: row['Note'],
          month: row['Month']
        }
      }
      sample = Sample.find_by(barcode: barcode)
      sample.update(attributes)
    end
  end

  task add_location_metadata_to_samples: :environment do
    include InsidePolygon
    locations = [
      {
        polygon: InsidePolygon::PILLAR_POINT_UNPROTECTED_EMBANKMENT,
        location: 'Pillar Point embankment unprotected'
      },
      {
        polygon: InsidePolygon::PILLAR_POINT_UNPROTECTED_EXPOSED,
        location: 'Pillar Point exposed unprotected'
      },
      {
        polygon: InsidePolygon::PILLAR_POINT_SMCA,
        location: 'Pillar Point SMCA'
      }
    ]

    project = ResearchProject.find_by(name: 'Pillar Point')

    sources = ResearchProjectSource.where(
      research_project: project, sourceable_type: 'Extraction'
    )

    sources.each do |source|
      sample = source.sourceable.sample
      locations.each do |location|
        point = [sample.latitude, sample.longitude]
        if inside_polygon(point, location[:polygon])
          source.metadata[:location] = location[:location]
          source.save
        end
      end
    end
  end

  task import_gbif_occurrences: :environment do
    puts 'import gbif ...'

    project_id = ResearchProject.find_by(name: 'Pillar Point').id

    locations = {
      embankment_unprotected: {
        file: 'PillarPoint_embankment_unprotected_GBIF_noCLO.csv',
        location: 'Pillar Point embankment unprotected'
      },
      exposed_unprotected: {
        file: 'PillarPoint_exposed_unprotected_GBIFnoCLO.csv',
        location: 'Pillar Point exposed unprotected'
      },
      SMCA: {
        file: 'PillarPointSMCA_GBIFnoCLO.csv',
        location: 'Pillar Point SMCA'
      },
      Montara_SMR: {
        file: 'Montara_SMR_GBIFnoCLO.csv',
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

  task import_top_inat_species: :environment do
    puts 'import top inat species'

    require_relative '../../db/data/private/pillar_point_inat_species'
    include PillarPointInatSpecies

    project = ResearchProject.find_by(name: 'Pillar Point')

    most_observed.each do |record|
      puts record[:name]
      request = GlobiRequest.create(
        taxon_id: ["INAT_TAXON:#{record[:inat_id]}"],
        taxon_name: record[:name]
      )

      ResearchProjectSource.create(
        research_project_id: project.id,
        sourceable_id: request.id,
        sourceable_type: 'GlobiRequest',
        metadata: record
      )
    end
  end
end
