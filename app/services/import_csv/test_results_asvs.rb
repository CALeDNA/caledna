# frozen_string_literal: true

module ImportCsv
  module TestResultsAsvs
    require 'csv'
    include ProcessTestResults
    include CsvUtils

    def import_csv(file, research_project_id, extraction_type_id)
      delimiter = delimiter_detector(file)

      ImportAsvCsvJob.perform_later(
        file.path, research_project_id, extraction_type_id, delimiter
      )

      OpenStruct.new(valid?: true, errors: nil)
    end

    # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
    def import_asv_csv(path, research_project_id, extraction_type_id, delimiter)
      data = CSV.read(path, headers: true, col_sep: delimiter)

      first_row = data.first
      sample_cells = first_row.headers[1..first_row.headers.size]
      extractions = get_extractions_from_headers(
        sample_cells, research_project_id, extraction_type_id
      )

      data.each do |row|
        taxonomy_string = row[row.headers.first]
        cal_taxon = find_cal_taxon_from_string(taxonomy_string)
        next if cal_taxon.blank?
        create_asvs(row, sample_cells, extractions, cal_taxon)
      end
    end
    # rubocop:enable Metrics/MethodLength, Metrics/AbcSize

    # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
    def convert_header_to_barcode(cell)
      sample = cell.split('_').last
      if /K\d{4}/.match?(sample)
        parts = sample.split('.')

        # NOTE: X16S_K0078.C2.S59.L001
        if parts.length == 4
          kit = parts.first
          location_letter = parts.second.split('').first
          sample_number = parts.second.split('').second
          "#{kit}-L#{location_letter}-S#{sample_number}"

        # NOTE: PITS_K0001A1.S1.L001
        elsif parts.length == 3
          match = /^(K\d{4})(\w)(\d)/.match(parts.first)
          kit = match[1]
          location_letter = match[2]
          sample_number = match[3]
          "#{kit}-L#{location_letter}-S#{sample_number}"
        else
          raise ImportError, 'invalid sample format'
        end

      # NOTE: X16S_11A1.S18.L001
      elsif /^\d{1,4}\w\d/.match?(sample)
        parts = sample.split('.')

        match = /(\d{1,4})(\w)(\d)/.match(parts.first)
        kit = "K#{match[1].rjust(4, '0')}"
        location_letter = match[2]
        sample_number = match[3]
        "#{kit}-L#{location_letter}-S#{sample_number}"
      else
        sample.split('.').first
      end
    end
    # rubocop:enable Metrics/MethodLength, Metrics/AbcSize

    private

    # rubocop:disable Metrics/MethodLength
    def get_extractions_from_headers(
      sample_cells, research_project_id, extraction_type_id
    )
      valid_extractions = {}

      sample_cells.each do |cell|
        barcode = convert_header_to_barcode(cell)
        extraction = find_extraction_from_barcode(barcode,
                                                  extraction_type_id,
                                                  :results_completed)
        valid_extractions[cell] = extraction

        ImportCsvCreateResearchProjectExtractionJob
          .perform_later(extraction, research_project_id)
      end
      valid_extractions
    end
    # rubocop:enable Metrics/MethodLength

    def create_asvs(row, sample_cells, extractions, cal_taxon)
      sample_cells.each do |cell|
        next if row[cell].to_i < 1

        extraction = extractions[cell]
        ImportCsvCreateAsvJob.perform_later(cell, extraction, cal_taxon)
      end
    end
  end
end

class ImportError < StandardError
end
