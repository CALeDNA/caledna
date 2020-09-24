# frozen_string_literal: true

namespace :gbif do
  task import_missing_fields_for_occ_taxa: :environment do
    api = GbifApi.new
    conn = ActiveRecord::Base.connection

    GbifOccTaxa.where(taxonkey: nil).each do |taxon|
      rank = taxon.taxonrank
      query = { rank: taxon.taxonrank }
      if rank == 'kingdom'
        query[:kingdom] = taxon.kingdom
        rank_sql = "AND kingdom = #{conn.quote(taxon.kingdom)}"
      elsif rank == 'phylum'
        query[:phylum] = taxon.phylum
        rank_sql = "AND phylum = #{conn.quote(taxon.phylum)}"
      elsif rank == 'class'
        query[:class] = taxon.classname
        rank_sql = "AND classname = #{conn.quote(taxon.classname)}"
      elsif rank == 'order'
        query[:order] = taxon.order
        rank_sql = "AND \"order\" = #{conn.quote(taxon.order)}"
      elsif rank == 'family'
        query[:family] = taxon.family
        rank_sql = "AND family = #{conn.quote(taxon.family)}"
      elsif rank == 'genus'
        query[:family] = taxon.family
        query[:genus] = taxon.genus
        rank_sql = "AND family = #{conn.quote(taxon.family)} " \
          "AND genus = #{conn.quote(taxon.genus)}"
      else
        next
      end

      response = api.taxa_by_rank(query)
      result = response.parsed_response

      puts result['usageKey']

      taxon.taxonkey = result['usageKey']
      taxon.scientificname = result['scientificName']
      sql = 'UPDATE external.gbif_occ_taxa ' \
      "SET taxonkey = #{result['usageKey']},  " \
      "scientificname = #{conn.quote(result['scientificName'])} " \
      "WHERE taxonrank = #{conn.quote(rank)} " \
      'AND taxonkey IS NULL '
      sql += rank_sql

      conn.execute(sql)
    end
  end

  # https://stackoverflow.com/a/29502094
  # bin/rake gbif:import_gbif_taxa'[/full/path]'
  task :import_gbif_taxa, [:path] => :environment do |_t, args|
    include CsvUtils

    path = args[:path]
    if path.blank?
      puts 'Must pass in path for taxa csv'
      next
    end

    puts 'importing taxa...'

    delim = delimiter_detector(OpenStruct.new(path: path))
    CSV.foreach(path, headers: true, col_sep: delim) do |row|
      attributes = {
        taxon_id: row['taxonKey'],
        scientific_name: row['scientificName'],
        accepted_taxon_id: row['acceptedTaxonKey'],
        accepted_scientific_name: row['acceptedScientificName'],
        taxon_rank: row['taxonRank'].downcase,
        taxonomic_status: row['taxonomicStatus'].downcase,
        kingdom: row['kingdom'],
        kingdom_id: row['kingdomKey'],
        phylum: row['phylum'],
        phylum_id: row['phylumKey'],
        class_name: row['class'],
        class_id: row['classKey'],
        order: row['order'],
        order_id: row['orderKey'],
        family: row['family'],
        family_id: row['familyKey'],
        genus: row['genus'],
        genus_id: row['genusKey'],
        species: row['species'],
        species_id: row['speciesKey']
      }
      PourGbifTaxon.create(attributes)
    end
  end

  task :import_gbif_occurrences, [:path] => :environment do |_t, args|
    include CsvUtils

    path = args[:path]
    if path.blank?
      puts 'Must pass in path for occurences csv'
      next
    end

    puts 'importing occurences...'

    delim = delimiter_detector(OpenStruct.new(path: path))
    def convert_date(field)
      return if field.blank?
      DateTime.parse(field)
    end

    datasets = {}

    PourGbifDataset.all.each do |dataset|
      datasets[dataset.dataset_key] = dataset.id
    end

    # https://stackoverflow.com/a/59353901
    # NOTE: using √ as quote_char because reader errors out if values has "
    CSV.foreach(path, headers: true, col_sep: delim,
                      encoding: 'bom|utf-8', quote_char: '√') do |row|
      attributes = {
        gbif_id: row['gbifID'],
        gbif_dataset_id: datasets[row['datasetKey']],
        occurrence_id: row['occurrenceID'],
        taxon_rank: row['taxonRank'].downcase,
        scientific_name: row['scientificName'],
        verbatim_scientific_name: row['verbatimScientificName'],
        verbatim_scientific_name_authorship:
          row['verbatimScientificNameAuthorship'],
        country_code: row['countryCode'],
        locality: row['locality'],
        occurrence_status: row['occurrenceStatus'],
        individual_count: row['individualCount'],
        publishing_org_key: row['publishingOrgKey'],
        state_province: row['stateProvince'],
        latitude: row['decimalLatitude'],
        longitude: row['decimalLongitude'],
        coordinate_uncertainty_in_meters: row['coordinateUncertaintyInMeters'],
        coordinate_precision: row['coordinatePrecision'],
        elevation: row['elevation'],
        elevation_accuracy: row['elevationAccuracy'],
        depth: row['depth'],
        depth_accuracy: row['depthAccuracy'],
        day: row['day'],
        month: row['month'],
        year: row['year'],
        geom: "POINT(#{row['decimalLongitude']} #{row['decimalLatitude']})",
        taxon_id: row['taxonKey'],
        species_id: row['speciesKey'],
        basis_of_record: row['basisOfRecord'],
        catalog_number: row['catalogNumber'],
        institution_code: row['institutionCode'],
        collection_code: row['collectionCode'],
        record_number: row['recordNumber'],
        identified_by: row['identifiedBy'],
        license: row['license'],
        rights_holder: row['rightsHolder'],
        recorded_by: row['recordedBy'],
        type_status: row['typeStatus'],
        establishment_means: row['establishmentMeans'],
        media_type: row['mediaType'],
        issue: row['issue'],
        event_date: convert_date(row['eventDate']),
        date_identified: convert_date(row['dateIdentified']),
        last_interpreted: convert_date(row['lastInterpreted'])
      }

      PourGbifOccurrence.create(attributes)
    end
  end

  task add_names_to_taxa: :environment do
    PourGbifTaxon.find_each do |taxon|
      puts taxon.taxon_id

      all_names = [taxon.kingdom, taxon.phylum, taxon.class_name, taxon.order,
                   taxon.family, taxon.genus, taxon.species].compact

      taxon.names = all_names
      taxon.save
    end
  end
end
