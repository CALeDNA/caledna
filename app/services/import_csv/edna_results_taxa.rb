# frozen_string_literal: true

module ImportCsv
  module EdnaResultsTaxa
    require 'csv'
    include ProcessEdnaResults
    include CsvUtils
    include CreateRecords

    # only import csv if first sum.taxonomy has valid taxa string. find
    # ResultTaxon, then update or create ResultTaxon
    def import_csv(file, research_project_id, primer)
      data = my_csv_read(file)

      first_result = data.entries.first['sum.taxonomy']

      if invalid_taxon?(first_result, strict: false)
        return OpenStruct.new(valid?: false,
                              errors: "#{first_result} is invalid format")
      end

      find_result_taxa(data, research_project_id, primer)

      OpenStruct.new(valid?: true, errors: nil)
    end

    def update_or_create_result_taxon(taxonomy_string, source_data)
      clean_str = remove_na(taxonomy_string)
      result_taxon =
        ResultTaxon.find_by(clean_taxonomy_string: clean_str)

      if result_taxon.present?
        update_result_taxon(result_taxon, source_data, taxonomy_string)
        return
      end

      create_result_taxon_from(taxonomy_string, source_data)
    end

    private

    def find_result_taxa(data, research_project_id, primer)
      data.entries.each do |row|
        taxonomy_string = row['sum.taxonomy']
        next if taxonomy_string.blank?

        # NOTE: disable creatind ResultRawImport for each csv row
        ImportCsvCreateResultRawImportJob
          .perform_later(row.to_h, research_project_id, primer)

        source_data = "#{research_project_id}|#{primer}"

        # ImportCsvUpdateOrCreateResultTaxonJob calls
        # update_or_create_result_taxon
        ImportCsvUpdateOrCreateResultTaxonJob.perform_later(
          taxonomy_string, source_data
        )
      end
    end


    def create_result_taxon_from(taxonomy_string, source_data)
      results = format_result_taxon_data_from_string(taxonomy_string)

      if results[:taxon_id].blank?
        data = { normalized: false, exact_match: false,
                 result_sources: [source_data] }
      elsif results[:taxon_id].present?
        data = { normalized: true, exact_match: true,
                 result_sources: [source_data] }
      end
      create_data = results.merge(data)

      create_result_taxon(create_data)
    end

    def update_result_taxon(result_taxon, source_data, taxonomy_string)
      unless result_taxon.result_sources.include?(source_data)
        result_taxon.result_sources << source_data
      end

      unless result_taxon.original_taxonomy_string.include?(taxonomy_string)
        result_taxon.original_taxonomy_string << taxonomy_string
      end
      result_taxon.save if result_taxon.changed?
    end
  end
end
