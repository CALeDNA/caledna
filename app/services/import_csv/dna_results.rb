# frozen_string_literal: true

module ImportCsv
  module DnaResults
    require 'csv'
    include ProcessTestResults
    include CsvUtils

    # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
    def import_csv(file, research_project_id, extraction_type_id)
      extractions = {}
      sample_cells = []
      missing_taxonomy = 0
      delimiter = delimiter_detector(file)

      CSV.foreach(file.path, headers: true, col_sep: delimiter) do |row|
        if extractions.empty?
          sample_cells = row.headers[1..row.headers.size]
          extractions = get_extractions_from_headers(
            sample_cells, research_project_id, extraction_type_id
          )
        end

        taxonomy_string = row[row.headers.first]
        taxon = find_taxon_from_string(taxonomy_string)
        if taxon.present? && taxon[:taxon_id].present?
          create_asvs(row, sample_cells, extractions, taxon)
        else
          missing_taxonomy += 1
        end
      end

      if missing_taxonomy.zero?
        OpenStruct.new(valid?: true, errors: nil)
      else
        message = "#{missing_taxonomy} taxonomies were not imported " \
          'because no match was found.'
        OpenStruct.new(valid?: false, errors: message)
      end
    end
    # rubocop:enable Metrics/MethodLength, Metrics/AbcSize

    # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
    def convert_header_to_barcode(cell)
      sample = cell.split('_').last
      if /K\d{4}/.match?(sample)
        parts = sample.split('.')

        if parts.length == 4
          kit = parts.first
          location_letter = parts.second.split('').first
          sample_number = parts.second.split('').second
          "#{kit}-L#{location_letter}-S#{sample_number}"
        elsif parts.length == 3
          match = /(K\d{4})(\w)(\d)/.match(cell)
          kit = match[1]
          location_letter = match[2]
          sample_number = match[3]
          "#{kit}-L#{location_letter}-S#{sample_number}"
        else
          raise ImportError, 'invalid sample format'
        end
      else
        sample.split('.').first
      end
    end
    # rubocop:enable Metrics/MethodLength, Metrics/AbcSize

    private

    def get_extractions_from_headers(
      sample_cells, research_project_id, extraction_type_id
    )
      valid_extractions = {}

      sample_cells.each do |cell|
        barcode = convert_header_to_barcode(cell)
        extraction = find_extraction_from_barcode(barcode, extraction_type_id)
        valid_extractions[cell] = extraction

        ImportCsvCreateResearchProjectExtractionJob
          .perform_later(extraction, research_project_id)
      end
      valid_extractions
    end

    def create_asvs(row, sample_cells, extractions, taxon)
      sample_cells.each do |cell|
        next if row[cell].to_i < 1

        extraction = extractions[cell]
        ImportCsvCreateAsvJob.perform_later(cell, extraction, taxon)
      end
    end
  end
end

class ImportError < StandardError
end
