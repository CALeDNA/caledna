# frozen_string_literal: true

namespace :pour do
  task :fix_pilot_coordinates, [:path] => :environment do |_t, args|
    require 'json'
    path = args[:path]

    data = JSON.parse(File.read(path))
    project = FieldProject.find_by(name: 'Los Angeles River')

    raise 'Cannot file project' if project.blank?

    data.each do |datum|
      puts datum['_id']
      results = Sample.where(field_project: project)
                      .where("(kobo_data ->> '_id')::INTEGER = ?", datum['_id'])

      next if results.blank?

      sample = results.first
      new_note = [
        sample.director_notes,
        "original coordinates: #{datum['latitude']}, #{datum['longitude']}"
      ].compact.join('; ')

      sample.update(latitude: datum['latitude'],
                    longitude: datum['longitude'],
                    director_notes: new_note)
    end
  end

  # https://stackoverflow.com/a/29502094
  # bin/rake pour:import_gbif_taxa'[/full/path]'
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
        rank: row['taxonRank'].downcase,
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

    dataset_id = PourGbifDataset.first.id

    delim = delimiter_detector(OpenStruct.new(path: path))
    def convert_date(field)
      return if field.blank?
      DateTime.parse(field)
    end

    CSV.foreach(path, headers: true, col_sep: delim,
                      encoding: 'bom|utf-8') do |row|
      attributes = {
        gbif_id: row['gbifID'],
        gbif_dataset_id: dataset_id,
        occurrence_id: row['occurrenceID'],
        infraspecific_epithet: row['infraspecificEpithet'],
        taxon_rank: row['taxonRank'].downcase,
        scientific_name: row['scientificName'],
        verbatim_scientific_name: row['verbatimScientificName'],
        country_code: row['countryCode'],
        state_province: row['stateProvince'],
        latitude: row['decimalLatitude'],
        longitude: row['decimalLongitude'],
        coordinate_uncertainty_in_meters: row['coordinateUncertaintyInMeters'],
        geom: "POINT(#{row['decimalLongitude']} #{row['decimalLatitude']})",
        taxon_id: row['taxonKey'],
        species_id: row['speciesKey'],
        basis_of_record: row['basisOfRecord'],
        catalog_number: row['catalogNumber'],
        identified_by: row['identifiedBy'],
        license: row['license'],
        rights_holder: row['rightsHolder'],
        recorded_by: row['recordedBy'],
        media_type: row['mediaType'],
        issue: row['issue'],
        event_date: convert_date(row['eventDate']),
        date_identified: convert_date(row['dateIdentified']),
        last_interpreted: convert_date(row['lastInterpreted'])
      }

      PourGbifOccurrence.create(attributes)
    end
  end
end
