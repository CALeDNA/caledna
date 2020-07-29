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
end

