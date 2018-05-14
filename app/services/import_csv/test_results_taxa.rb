# frozen_string_literal: true

module ImportCsv
  module TestResultsTaxa
    require 'csv'
    include ProcessTestResults
    include CsvUtils

    def import_csv(file)
      delimiter = delimiter_detector(file)

      ImportTaxonomyCsvJob.perform_later(file.path, delimiter)

      OpenStruct.new(valid?: true, errors: nil)
    end

    # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
    def import_taxomony_csv(path, delimiter)
      CSV.foreach(path, headers: true, col_sep: delimiter) do |row|
        taxonomy_string = row[row.headers.first]
        results = find_taxon_from_string(taxonomy_string)

        cal_taxon =
          CalTaxon.find_by(original_taxonomy: results[:original_taxonomy])
        next if cal_taxon.present?

        if results[:taxon_id].blank? && results[:rank].present?
          create_data = taxon_not_found(results)
        elsif results[:taxon_id].present? && results[:rank].present?
          create_data = taxon_found(results)
        end

        ImportCsvCreateCalTaxonJob.perform_later(create_data)
      end
    end
    # rubocop:enable Metrics/MethodLength, Metrics/AbcSize

    def taxon_not_found(results)
      {
        taxonRank: results[:rank],
        original_hierarchy: results[:original_hierarchy],
        original_taxonomy: results[:original_taxonomy],
        complete_taxonomy: results[:complete_taxonomy],
        normalized: false,
        exact_gbif_match: false
      }
    end

    def taxon_found(results)
      {
        taxonRank: results[:rank],
        original_hierarchy: results[:original_hierarchy],
        original_taxonomy: results[:original_taxonomy],
        complete_taxonomy: results[:complete_taxonomy],
        normalized: true,
        exact_gbif_match: true,
        taxonID: results[:taxon_id]
      }
    end
  end
end
