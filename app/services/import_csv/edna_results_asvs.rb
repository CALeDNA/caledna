# frozen_string_literal: true

module ImportCsv
  module EdnaResultsAsvs
    require 'csv'
    include ProcessEdnaResults
    include CsvUtils

    # rubocop:disable Metrics/MethodLength
    def import_csv(file, research_project_id, extraction_type_id, primer)
      delimiter = delimiter_detector(file)
      data = CSV.read(file.path, headers: true, col_sep: delimiter)

      barcodes = convert_headers_to_barcodes(data)
      samples = find_samples_from_barcodes(barcodes)

      if samples[:invaild_barcodes].present?
        message = "#{samples[:invaild_barcodes].join(', ')} not in the database"
        return OpenStruct.new(valid?: false, errors: message)
      end

      ImportCsvQueueAsvJob.perform_later(
        data.to_json, research_project_id, extraction_type_id, primer
      )

      OpenStruct.new(valid?: true, errors: nil)
    end
    # rubocop:enable Metrics/MethodLength

    def convert_headers_to_barcodes(data)
      first_row = data.first
      raw_sample_barcodes = first_row.headers[1..first_row.headers.size]

      raw_sample_barcodes.map do |raw_barcode|
        convert_raw_barcode(raw_barcode)
      end.compact
    end

    def find_samples_from_barcodes(barcodes)
      invaild_barcodes = []
      valid_samples = []

      barcodes.each do |barcode|
        sample = Sample.approved.find_by(barcode: barcode)
        sample.present? ? valid_samples << sample : invaild_barcodes << barcode
      end

      { invaild_barcodes: invaild_barcodes, valid_samples: valid_samples }
    end

    # rubocop:disable Metrics/MethodLength
    def queue_asv_job(data_json, research_project_id, extraction_type_id,
                      primer)
      data = JSON.parse(data_json)
      headers = data.first
      raw_sample_barcodes = headers[1..headers.size]

      extractions = get_extractions_from_headers(
        raw_sample_barcodes, research_project_id, extraction_type_id
      )

      data.each do |row|
        next if row.first == 'sum.taxonomy'
        taxonomy_string = row.first
        next if invalid_taxon?(taxonomy_string)

        cal_taxon = find_cal_taxon_from_string(taxonomy_string)
        next if cal_taxon.blank?

        create_asvs(row, raw_sample_barcodes, extractions, cal_taxon, primer)
      end
    end
    # rubocop:enable Metrics/MethodLength

    # rubocop:disable Metrics/MethodLength
    def get_extractions_from_headers(
      sample_cells, research_project_id, extraction_type_id
    )
      valid_extractions = {}

      sample_cells.each do |cell|
        next if cell.nil?

        barcode = convert_raw_barcode(cell)
        next if barcode.nil?

        extraction = find_extraction_from_barcode(barcode,
                                                  extraction_type_id,
                                                  :results_completed)
        valid_extractions[cell] = extraction

        ImportCsvCreateResearchProjectSourceJob
          .perform_later(extraction, research_project_id)
      end
      valid_extractions
    end
    # rubocop:enable Metrics/MethodLength

    private

    def create_asvs(row, sample_cells, extractions, cal_taxon, primer)
      sample_cells.each do |cell|
        index = sample_cells.index(cell)
        count = row[index + 1].to_i
        next if count < 1

        extraction = extractions[cell]
        next if extraction.blank?

        ImportCsvCreateAsvJob.perform_later(cell, extraction, cal_taxon, count,
                                            primer)
      end
    end
  end
end

class ImportError < StandardError
end
