# frozen_string_literal: true

module ImportCsv
  module EdnaResultsTaxa
    require 'csv'
    include ProcessEdnaResults
    include CsvUtils

    # rubocop:disable Metrics/MethodLength
    def import_csv(file, research_project_id, primer)
      delimiter = delimiter_detector(file)

      CSV.foreach(file.path, headers: true, col_sep: delimiter) do |row|
        taxonomy_string = row[row.headers.first]
        next if invalid_taxon?(taxonomy_string)

        if taxon_has_results?(row)
          ImportCsvCreateRawTaxonomyImportJob.perform_later(
            taxonomy_string, research_project_id, primer
          )
        end

        ImportCsvFindCalTaxonJob.perform_later(taxonomy_string)
      end

      OpenStruct.new(valid?: true, errors: nil)
    end
    # rubocop:enable Metrics/MethodLength

    def find_cal_taxon(taxonomy_string)
      cal_taxon =
        CalTaxon.find_by(original_taxonomy_string: taxonomy_string)

      return if cal_taxon.present?

      create_cal_taxon_from(taxonomy_string)
    end

    private

    def taxon_has_results?(row)
      row.to_h.except('sum.taxonomy').values.uniq != ['0']
    end

    def create_cal_taxon_from(taxonomy_string)
      results = format_cal_taxon_data_from_string(taxonomy_string)

      if results[:taxon_id].blank?
        create_data = results.merge(normalized: false)
      elsif results[:taxon_id].present?
        create_data = results.merge(normalized: true)
      end

      ImportCsvCreateCalTaxonJob.perform_later(create_data)
    end
  end
end
