# frozen_string_literal: true

module ImportCsv
  module SamplesResearchMetadata
    require 'csv'
    include CsvUtils
    include ProcessEdnaResults

    # only import csv if all barcodes are in database. create or update
    # research project sources
    # rubocop:disable Metrics/MethodLength
    def import_csv(file, research_project_id)
      data = my_csv_read(file)

      unless data.headers.include?('sum.taxonomy')
        message =
          'The column with the samples names must be called "sum.taxonomy"'
        return OpenStruct.new(valid?: false, errors: message)
      end

      new_barcodes =
        process_barcodes_for_csv_table(data, 'sum.taxonomy')[:new_barcodes]
      if new_barcodes.present?
        message = "#{new_barcodes.join(', ')} not in the database"
        return OpenStruct.new(valid?: false, errors: message)
      end

      create_or_update_research_proj_sources(data, research_project_id)
      OpenStruct.new(valid?: true, errors: nil)
    end
    # rubocop:enable Metrics/MethodLength

    def create_or_update_research_proj_source(row, barcode, research_project_id)
      sample = Sample.approved.find_by(barcode: barcode)
      return if sample.blank?

      source =
        ResearchProjectSource.where(sourceable: sample)
                             .where(research_project_id: research_project_id)
                             .first_or_create

      source.metadata =
        row.reject { |k, _v| k == 'sum.taxonomy' || k.blank? }.to_h
      source.save
    end

    private

    def create_or_update_research_proj_sources(data, research_project_id)
      data.entries.each do |row|
        next if row['sum.taxonomy'].blank?

        barcode = convert_raw_barcode(row['sum.taxonomy'])
        next if barcode.blank?

        clean_row = row.to_h.reject { |k, _v| k.blank? }
        ImportCsvCreateOrUpdateResearchProjSourceJob
          .perform_later(clean_row, barcode, research_project_id)
      end
    end
  end
end
