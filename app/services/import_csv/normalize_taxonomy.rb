# frozen_string_literal: true

module ImportCsv
  module NormalizeTaxonomy
    require 'csv'
    include ProcessTestResults

    # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
    def normalize_taxonomy(file)
      missing_taxonomy = 0

      CSV.foreach(file.path, headers: true) do |row|
        taxonomy_string = row[row.headers.first]
        results = find_taxon_from_string(taxonomy_string)
        if results[:taxonID].blank? && results[:rank].present?
          missing_taxonomy += 1

          cal_taxon =
            CalTaxon.find_by(original_taxonomy: results[:original_taxonomy])
          next if cal_taxon.present?

          CalTaxon.create(
            taxonRank: results[:rank],
            original_hierarchy: results[:original_hierarchy],
            original_taxonomy: results[:original_taxonomy],
            complete_taxonomy: results[:complete_taxonomy],
            normalized: false
          )
        end
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
