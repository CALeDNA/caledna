# frozen_string_literal: true

module ImportCsv
  module SamplesResearchMetadata
    require 'csv'
    include CsvUtils
    include ProcessEdnaResults

    def import_csv(file, research_project_id)
      delimiter = delimiter_detector(file)
      data = CSV.read(file.path, headers: true, col_sep: delimiter)

      new_barcodes =
        process_barcodes_for_csv_table(data, 'sum.taxonomy')[:new_barcodes]
      if new_barcodes.present?
        message = "#{new_barcodes.join(', ')} not in the database"
        return OpenStruct.new(valid?: false, errors: message)
      end

      update_research_project_sources(data, research_project_id)
      OpenStruct.new(valid?: true, errors: nil)
    end

    private

    def update_research_project_sources(data, research_project_id)
      data.entries.each do |row|
        barcode = row['sum.taxonomy']
        next if barcode.blank?

        sample = Sample.find_by(barcode: barcode)
        update_research_project_source(row, sample, research_project_id)
      end
    end

    def update_research_project_source(row, sample, research_project_id)
      source =
        ResearchProjectSource.where(sourceable: sample)
                             .where(research_project_id: research_project_id)
                             .first_or_create

      source.metadata = row.reject { |k, _v| k == 'sum.taxonomy' || k.blank? }.to_h
      source.save
    end
  end
end
