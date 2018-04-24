# frozen_string_literal: true

module ImportCsv
  module NormalizeTaxonomy
    require 'csv'
    include ProcessTestResults
    include CsvUtils

    # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
    def import_csv(file)
      missing_taxonomy = 0
      delimiter = delimiter_detector(file)

      CSV.foreach(file.path, headers: true, col_sep: delimiter) do |row|
        taxonomy_string = row[row.headers.first]
        results = find_taxon_from_string(taxonomy_string)

        cal_taxon =
          CalTaxon.find_by(original_taxonomy: results[:original_taxonomy])
        next if cal_taxon.present?

        if results[:taxonID].blank? && results[:rank].present?
          missing_taxonomy += 1
          create_data = {
            taxonRank: results[:rank],
            original_hierarchy: results[:original_hierarchy],
            original_taxonomy: results[:original_taxonomy],
            complete_taxonomy: results[:complete_taxonomy],
            normalized: false,
            exact_gbif_match: false
          }
        elsif results[:taxonID].present? && results[:rank].present?
          create_data = {
            taxonRank: results[:rank],
            original_hierarchy: results[:original_hierarchy],
            original_taxonomy: results[:original_taxonomy],
            complete_taxonomy: results[:complete_taxonomy],
            normalized: true,
            exact_gbif_match: true,
            taxonID: results[:taxonID]
          }
        end
        ImportCsvCreateCalTaxonJob.perform_later(create_data)
      end

      if missing_taxonomy.zero?
        OpenStruct.new(valid?: true, errors: nil)
      else
        message = "There are #{missing_taxonomy} taxonomies that need " \
          'to be reviewed.'
        OpenStruct.new(valid?: false, errors: message)
      end
    end
    # rubocop:enable Metrics/MethodLength, Metrics/AbcSize
  end
end
