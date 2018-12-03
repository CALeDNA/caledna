# frozen_string_literal: true

namespace :combine_taxa do
  require 'csv'
  require_relative '../../app/services/import_combine_taxa'
  include ImportCombineTaxa

  desc 'import taxa from Ruggiero paper csv'
  task import_research_paper: :environment do
    path =  ENV['file']

    ranks = %w[
      superkingdom kingdom subkingdom infrakingdom superphylum phylum subphylum
      infraphylum superclass class subclass infraclass superorder order
    ]
    taxa_data = {}
    taxa_history = {}
    column_with_taxon_index = 0

    ranks.each do |rank|
      taxa_history[rank] = nil
    end

    CSV.foreach(path, headers: true, col_sep: ',') do |row|
      puts row

      ranks.each.with_index do |rank, index|
        if row[rank].present?
          taxa_data = parse_taxon(row[rank])
          next if taxa_data.blank?

          name = taxa_data[:name]
          next if name.blank?

          taxa_history[rank] = name

          if column_with_taxon_index > index
            [*(index + 1)..ranks.length].each do |num|
              taxa_history[ranks[num]] = nil
            end
          end
          column_with_taxon_index = index
        end
      end

      next if taxa_data.blank?

      hierarchy_names = taxa_history.reject { |_k, v| v.blank? }
      full_taxonomy_string = taxa_history.values.join(';')

      attributes = {
        source: 'paper',
        notes: taxa_data[:notes],
        full_taxonomy_string: full_taxonomy_string
      }

      if taxa_data[:name].present?
        attributes.merge!(
          superkingdom: taxa_history['superkingdom'],
          kingdom: taxa_history['kingdom'],
          phylum: taxa_history['phylum'],
          class_name: taxa_history['class'],
          order: taxa_history['order'],
          family: taxa_history['family'],
          genus: taxa_history['genus'],
          species: taxa_history['species'],
          synonym: taxa_data[:synonym],
          taxon_rank: taxa_data[:rank],
          hierarchy_names: hierarchy_names,
          short_taxonomy_string:
            create_combine_taxa_taxonomy_string(taxa_history)
        )
      end

      CombineTaxon.create(attributes)
    end
  end

  #  bin/rake combine_taxa:import_unique_found_taxa file=xxx
  desc 'import eDNA and gbif unique taxa from Pillar Point'
  task import_unique_found_taxa: :environment do
    path = ENV['file']

    CSV.foreach(path, headers: true) do |row|
      taxon =
        CombineTaxon.where(taxon_id: row['taxon_id'], source: row['source'])
      next if taxon.present?

      row.to_h.each { |k, v| row[k] = v&.strip }

      if row['source'] == 'ncbi' || row['source'] == 'gbif'
        CombineTaxon.create(
          source: row['source'],
          taxon_id: row['taxon_id'],
          source_superkingdom: row['superkingdom'],
          source_kingdom: row['kingdom'],
          source_phylum: row['phylum'],
          source_class_name: row['class'],
          source_order: row['order'],
          source_family: row['family'],
          source_genus: row['genus'],
          source_species: row['species'],
          cal_division_id: row['cal_division_id'],
          taxon_rank: row['taxon_rank']
        )
      end
    end
  end

  #  bin/rake combine_taxa:export_asv_results file=data/edna/xxx
  task export_asv_results: :environment do
    file = ENV['file']
    file_name = file.split('/').last
    path = "#{Rails.root}/#{file}"
    output_file = "data/converted/converted_#{file_name}"

    append_header(path, output_file)

    CSV.foreach(path, headers: true, col_sep: "\t") do |row|
      cal_taxon = find_cal_taxon(row['sum.taxonomy'])

      taxon = NcbiNode.find(cal_taxon.taxonID)
      taxon_id = taxon.ncbi_id || taxon.bold_id
      source = taxon.ncbi_id.present? ? 'ncbi' : 'bold'

      CSV.open(output_file, 'a+') do |csv|
        if cal_taxon.present?
          combine_taxon =
            CombineTaxon.where(taxon_id: cal_taxon.taxonID, source: 'ncbi')
                        .first

          # rubocop:disable Style/ConditionalAssignment
          if combine_taxon.present?
            csv << [source, taxon_id, combine_taxon.short_taxonomy_string] +
                   row.to_h.values
          else
            csv << ['', '', 'no combine'] + row.to_h.values
          end
          # rubocop:enable Style/ConditionalAssignment
        else
          csv << ['', '', 'no cal'] + row.to_h.values
        end
      end
    end
  end
end
