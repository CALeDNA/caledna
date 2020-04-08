# frozen_string_literal: true

module ImportCsv
  module EdnaResultsTaxa
    require 'csv'
    include ProcessEdnaResults
    include CsvUtils

    def import_csv(file, research_project_id, primer)
      delimiter = delimiter_detector(file)
      data = CSV.read(file.path, headers: true, col_sep: delimiter)

      first_result = data.entries.first['sum.taxonomy']
      if invalid_taxon?(first_result)
        return OpenStruct.new(valid?: false,
                              errors: "#{first_result} is invalid format")
      end

      find_result_taxa(data, research_project_id, primer)

      OpenStruct.new(valid?: true, errors: nil)
    end

    def find_result_taxon(taxonomy_string, source_data)
      result_taxon =
        ResultTaxon.find_by(original_taxonomy_string: taxonomy_string)

      if result_taxon.present? && !result_taxon.sources.include?(source_data)
        result_taxon.sources << source_data
        result_taxon.save
        return
      end

      create_result_taxon_from(taxonomy_string, source_data)
    end

    private

    def find_result_taxa(data, research_project_id, primer)
      data.entries.each do |row|
        source_data = "#{research_project_id}|#{primer}"
        taxonomy_string = row['sum.taxonomy']
        ImportCsvFindResultTaxonJob.perform_later(taxonomy_string, source_data)
      end
    end

    def create_result_taxon_from(taxonomy_string, source_data)
      results = format_result_taxon_data_from_string(taxonomy_string)

      if results[:taxon_id].blank?
        data = { normalized: false, exact_match: false, sources: [source_data] }
      elsif results[:taxon_id].present?
        data = { normalized: true, exact_match: true, sources: [source_data] }
      end
      create_data = results.merge(data)

      ImportCsvCreateResultTaxonJob.perform_later(create_data)
    end
  end
end
