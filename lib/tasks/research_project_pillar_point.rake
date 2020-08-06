# frozen_string_literal: true

namespace :research_project_pillar_point do
  require 'csv'

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
        polygon: InsidePolygon::PILLAR_POINT_UNPROTECTED_EMBAYMENT,
        location: 'Pillar Point embayment unprotected'
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
      research_project: project, sourceable_type: 'Sample'
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
      embayment_unprotected: {
        file: 'PillarPoint_embayment_unprotected_GBIF_noCLO.csv',
        location: 'Pillar Point embayment unprotected'
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
      { taxon_id: 5_043_762, bold_id: 515_404, ncbi_id: 1_405_418 },
      { taxon_id: 5_043_358, bold_id: 23_719, ncbi_id: 4783 }
    ]

    taxa.each do |taxon|
      asvs = Asv.where(taxon_id: taxon[:taxon_id])
      asvs.each do |asv|
        asv.update(taxon_id: taxon[:ncbi_id])
      end

      result_taxon = ResultTaxon.where(taxon_id: taxon[:taxon_id])
      result_taxon.update(taxon_id: taxon[:ncbi_id], exact_gbif_match: true)

      NcbiNode.where(taxon_id: taxon[:taxon_id]).destroy_all

      node = NcbiNode.find_by(taxon_id: taxon[:ncbi_id])
      node.bold_id = taxon[:bold_id]
      node.save
    end
  end

  task add_ids_to_bold_taxa: :environment do
    taxa = [
      { taxon_id: 5_043_071, bold_id: 491_488, ncbi_id: nil },
      { taxon_id: 5_042_993, bold_id: 370_424, ncbi_id: nil },
      { taxon_id: 5_043_237, bold_id: 109_576, ncbi_id: nil },
      { taxon_id: 5_043_324, bold_id: 461_346, ncbi_id: nil },
      { taxon_id: 5_043_166, bold_id: 282_232, ncbi_id: nil },
      { taxon_id: 5_043_144, bold_id: 519_820, ncbi_id: nil },
      { taxon_id: 5_043_154, bold_id: 217_039, ncbi_id: nil },
      { taxon_id: 5_043_028, bold_id: 258_990, ncbi_id: nil },
      { taxon_id: 5_043_434, bold_id: 346_023, ncbi_id: nil },
      { taxon_id: 5_043_437, bold_id: 527_120, ncbi_id: nil },
      { taxon_id: 5_043_085, bold_id: 534_591, ncbi_id: nil },
      { taxon_id: 5_042_985, bold_id: 854_055, ncbi_id: nil },
      { taxon_id: 5_043_740, bold_id: 268_203, ncbi_id: nil },
      { taxon_id: 5_043_453, bold_id: 85_116, ncbi_id: nil },
      { taxon_id: 5_043_751, bold_id: 268_558, ncbi_id: nil },
      { taxon_id: 5_043_840, bold_id: 275_367, ncbi_id: nil },
      { taxon_id: 5_043_057, bold_id: 718_901, ncbi_id: nil },
      { taxon_id: 5_043_841, bold_id: 720_297, ncbi_id: nil },
      { taxon_id: 5_043_842, bold_id: 720_439, ncbi_id: nil },
      { taxon_id: 5_043_729, bold_id: 737_713, ncbi_id: nil },
      { taxon_id: 5_043_697, bold_id: 669_159, ncbi_id: nil },
      { taxon_id: 5_042_987, bold_id: 510_195, ncbi_id: nil },
      { taxon_id: 5_043_221, bold_id: 299_402, ncbi_id: nil },
      { taxon_id: 5_043_633, bold_id: 231_769, ncbi_id: nil },
      { taxon_id: 5_043_168, bold_id: 542_750, ncbi_id: 2_203_571 },
      { taxon_id: 5_043_833, bold_id: 596_352, ncbi_id: nil },
      { taxon_id: 5_043_788, bold_id: 101_974, ncbi_id: nil },
      { taxon_id: 5_043_139, bold_id: 726_913, ncbi_id: nil },
      { taxon_id: 5_043_018, bold_id: 309_823, ncbi_id: 2_316_222 },
      { taxon_id: 5_043_353, bold_id: 53_944, ncbi_id: nil },
      { taxon_id: 5_043_454, bold_id: 276_756, ncbi_id: nil },
      { taxon_id: 5_043_839, bold_id: 646_268, ncbi_id: nil },
      { taxon_id: 5_043_421, bold_id: 194_539, ncbi_id: nil },
      { taxon_id: 5_043_070, bold_id: 641_458, ncbi_id: nil },
      { taxon_id: 5_042_978, bold_id: 385_908, ncbi_id: nil },
      { taxon_id: 5_042_975, bold_id: 30_651, ncbi_id: 2_109_251 },
      { taxon_id: 5_043_456, bold_id: 343_866, ncbi_id: nil },
      { taxon_id: 5_043_000, bold_id: 606_438, ncbi_id: nil },
      { taxon_id: 5_043_153, bold_id: 396_830, ncbi_id: 2_049_150 },
      { taxon_id: 5_043_800, bold_id: 353_344, ncbi_id: nil },
      { taxon_id: 5_043_801, bold_id: 111_079, ncbi_id: nil },
      { taxon_id: 5_043_803, bold_id: 730_955, ncbi_id: nil },
      { taxon_id: 5_043_368, bold_id: 311_958, ncbi_id: nil },
      { taxon_id: 5_043_808, bold_id: 268_483, ncbi_id: nil },
      { taxon_id: 5_042_998, bold_id: 706_900, ncbi_id: nil },
      { taxon_id: 5_043_641, bold_id: 234_301, ncbi_id: 2_183_729 },
      { taxon_id: 5_043_079, bold_id: 572_570, ncbi_id: nil },
      { taxon_id: 5_043_395, bold_id: 182_772, ncbi_id: nil },
      { taxon_id: 5_043_396, bold_id: 179_273, ncbi_id: nil },
      { taxon_id: 5_043_119, bold_id: 373_457, ncbi_id: nil },
      { taxon_id: 5_043_812, bold_id: 381_019, ncbi_id: nil },
      { taxon_id: 5_043_326, bold_id: 655_394, ncbi_id: nil },
      { taxon_id: 5_043_009, bold_id: 606_440, ncbi_id: nil },
      { taxon_id: 5_043_146, bold_id: 181_364, ncbi_id: nil },
      { taxon_id: 5_043_739, bold_id: 735_500, ncbi_id: nil },
      { taxon_id: 5_043_174, bold_id: 542_515, ncbi_id: nil },
      { taxon_id: 5_043_680, bold_id: 85_217, ncbi_id: nil },
      { taxon_id: 5_043_087, bold_id: 271_367, ncbi_id: nil },
      { taxon_id: 5_043_741, bold_id: 769_336, ncbi_id: 2_202_239 }
    ]

    taxa.each do |taxon|
      node = NcbiNode.find(taxon[:taxon_id])
      node.update(bold_id: taxon[:bold_id], ncbi_id: taxon[:ncbi_id])
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

  task add_missing_gbif_occ_taxa: :environment do
    sql = <<~SQL
      INSERT INTO external.gbif_occ_taxa (kingdom, phylum, classname,
      "order", family, genus,
      species, infraspecificepithet, taxonrank,
      scientificname, taxonkey)

      SELECT gbif_occurrences.kingdom, gbif_occurrences.phylum,
      gbif_occurrences.classname, gbif_occurrences."order",
      gbif_occurrences.family, gbif_occurrences.genus,
      gbif_occurrences.species, gbif_occurrences.infraspecificepithet,
      lower(gbif_occurrences.taxonrank) as taxonrank,
      gbif_occurrences.scientificname, gbif_occurrences.taxonkey
      FROM external.gbif_occurrences
      LEFT JOIN external.gbif_occ_taxa
      ON gbif_occ_taxa.taxonkey = gbif_occurrences.taxonkey
      WHERE gbif_occ_taxa.taxonkey IS NULL
      GROUP BY gbif_occurrences.kingdom,  gbif_occurrences.phylum,
      gbif_occurrences.classname, gbif_occurrences."order",
      gbif_occurrences.family, gbif_occurrences.genus,
      gbif_occurrences.species, gbif_occurrences.infraspecificepithet,
      gbif_occurrences.taxonrank, gbif_occurrences.scientificname,
      gbif_occurrences.taxonkey;
    SQL
    conn.exec_query(sql)
  end

  task populate_globi_show: :environment do
    project = ResearchProject.find_by(slug: 'pillar-point')

    sql = 'SELECT taxon_name from pillar_point.globi_index;'
    taxa = conn.exec_query(sql)
    taxa.each do |row|
      taxon = row['taxon_name']
      puts taxon

      params = { taxon: taxon }
      pp = ResearchProjectService::PillarPoint.new(project, params)
      pp.globi_interactions.each do |record|
        print '.'
        GlobiShow.create(record.merge(keyword: taxon))
      end
    end
  end

  def conn
    @conn ||= ActiveRecord::Base.connection
  end
end
