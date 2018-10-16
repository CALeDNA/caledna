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

  task remove_duplicate_ncbi_taxa: :environment do
    taxa = [
      { taxon_id: 5043762, bold_id: 515404, ncbi_id: 1405418 },
      { taxon_id: 5043358, bold_id: 23719, ncbi_id: 4783 }
    ]

    taxa.each do |taxon|
      asvs = Asv.where(taxonID: taxon[:taxon_id])
      asvs.each do |asv|
        asv.update(taxonID: taxon[:ncbi_id])
      end

      cal_taxon = CalTaxon.where(taxonID: taxon[:taxon_id])
      cal_taxon.update(taxonID: taxon[:ncbi_id], exact_gbif_match: true)

      NcbiNode.where(taxon_id: taxon[:taxon_id]).destroy_all

      node = NcbiNode.find_by(taxon_id: taxon[:ncbi_id])
      node.bold_id = taxon[:bold_id]
      node.save
    end
  end
  task create_interaction_csv: :environment do
    require 'csv'

    project = ResearchProject.find_by(name: 'Pillar Point')
    params = {}
    pp = ResearchProjectService::PillarPoint.new(project, params)
    sql = pp.globi_index_sql
    raw_records = conn.exec_query(sql).to_a

    CSV.open('pillar_pointinteractions.csv', 'wb', col_sep: "\t") do |csv|
      csv << %w[
        keyword
        source_taxon_name
        source_taxon_rank
        source_taxon_path
        interaction
        target_taxon_name
        target_taxon_rank
        target_taxon_path
        edna_match
        gbif_match
      ]

      raw_records.each do |request|
        taxon = request['taxon_name']
        params = { taxon: taxon }

        puts taxon

        pp = ResearchProjectService::PillarPoint.new(project, params)
        pp.globi_interactions.each do |interaction|
          csv << [
            taxon,
            interaction['source_taxon_name'],
            interaction['source_taxon_rank'],
            interaction['source_taxon_path'],
            interaction['interaction_type'],
            interaction['target_taxon_name'],
            interaction['target_taxon_rank'],
            interaction['target_taxon_path'],
            interaction['edna_match'],
            interaction['gbif_match']
          ]
        end
      end
    end
  end

  def conn
    @conn ||= ActiveRecord::Base.connection
  end
end
