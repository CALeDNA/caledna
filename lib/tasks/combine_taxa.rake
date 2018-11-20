# frozen_string_literal: true

namespace :combine_taxa do
  require 'csv'

  #  bin/rake combine_taxa:import file=data/combined_taxa_complete.csv
  task import: :environment do
    path = "#{Rails.root}/#{ENV['file']}"

    def create_taxonomy_string(row)
      "#{row['superkingdom']};#{row['phylum']};#{row['class']};" \
      "#{row['order']};#{row['family']};#{row['genus']};#{row['species']}"
    end

    CSV.foreach(path, headers: true) do |row|
      taxon =
        CombineTaxon.where(taxon_id: row['taxon_id'], source: row['source'])
      next if taxon.present?

      row.to_h.each { |k, v| row[k] = v&.strip }

      if row['source'] == 'ncbi' || row['source'] == 'gbif'
        CombineTaxon.create(
          source: row['source'],
          taxon_id: row['taxon_id'],
          superkingdom: row['superkingdom'],
          kingdom: row['kingdom'],
          phylum: row['phylum'],
          class_name: row['class'],
          order: row['order'],
          family: row['family'],
          genus: row['genus'],
          species: row['species'],
          caledna_taxonomy_string: create_taxonomy_string(row),
          notes: row['notes']
        )
      end
    end
  end

  #  bin/rake combine_taxa:export_asv_results file=data/edna/xxx
  task export_asv_results: :environment do
    def append_header(path, output_file)
      content = CSV.read(path, headers: true, col_sep: "\t")
      CSV.open(output_file, 'a+') do |csv|
        csv << %w[source taxon_id caledna_taxonomy] + content.headers
      end
    end

    def find_cal_taxon(original_taxonomy)
      taxonomy = original_taxonomy.gsub(/^.*?;/, '')
      sql = 'original_taxonomy_phylum = ? OR ' \
        'original_taxonomy_superkingdom = ?'

      CalTaxon.where(sql, taxonomy, taxonomy).first
    end

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
            csv << [source, taxon_id, combine_taxon.caledna_taxonomy_string] +
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
