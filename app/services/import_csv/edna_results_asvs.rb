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

      first_row = data.first
      sample_cells = first_row.headers[1..first_row.headers.size]
      extractions = get_extractions_from_headers(
        sample_cells, research_project_id, extraction_type_id
      )

      ImportCsvQueueAsvJob.perform_later(
        data.to_json, sample_cells, extractions, primer
      )

      OpenStruct.new(valid?: true, errors: nil)
    end
    # rubocop:enable Metrics/MethodLength

    def queue_asv_job(data, sample_cells, extractions, primer)
      JSON.parse(data).each do |row|
        next if row.first == 'sum.taxonomy'
        taxonomy_string = row.first
        next if invalid_taxon?(taxonomy_string)

        cal_taxon = find_cal_taxon_from_string(taxonomy_string)
        next if cal_taxon.blank?

        create_asvs(row, sample_cells, extractions, cal_taxon, primer)
      end
    end

    # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
    # rubocop:disable Metrics/PerceivedComplexity, Metrics/CyclomaticComplexity
    def convert_header_to_barcode(cell)
      sample = cell.split('_').last
      parts = sample.split('.')

      # NOTE: dot notation. X16S_K0078.C2.S59.L001
      if /^(K\d{4})\.([ABC][12])\./.match?(sample)
        kit = parts.first
        location_letter = parts.second.split('').first
        sample_number = parts.second.split('').second
        "#{kit}-L#{location_letter}-S#{sample_number}"

      # NOTE: K_L_S_. 'X12S_K0124LBS2.S16.L001'
      elsif /^K(\d{1,4})(L[ABC])(S[12])\./.match?(sample)
        match = /^K(\d{1,4})(L[ABC])(S[12])/.match(parts.first)
        kit = match[1].rjust(4, '0')
        location_letter = match[2]
        sample_number = match[3]
        "K#{kit}-#{location_letter}-#{sample_number}"

      # NOTE: K_S_L_. 'X12S_K0404S1LA.S1.L001'
      elsif /^K(\d{1,4})(S[12])(L[ABC])\./.match?(sample)
        match = /^K(\d{1,4})(S[12])(L[ABC])/.match(parts.first)
        kit = match[1].rjust(4, '0')
        location_letter = match[3]
        sample_number = match[2]
        "K#{kit}-#{location_letter}-#{sample_number}"

      # NOTE: K_S_L_R_. 'X18S_K0403S1LBR1.S16.L001'
      elsif /^K(\d{1,4})(S[12])(L[ABC])(R\d)\./.match?(sample)
        match = /^K(\d{1,4})(S[12])(L[ABC])(R\d)/.match(parts.first)
        kit = match[1].rjust(4, '0')
        location_letter = match[3]
        sample_number = match[2]
        replicate_number = match[4]
        "K#{kit}-#{location_letter}-#{sample_number}-#{replicate_number}"

      # NOTE: K_LS. PITS_K0001A1.S1.L001
      # NOTE: _LS. X16S_11A1.S18.L001
      elsif /^K?\d{1,4}[ABC][12]\./.match?(sample)
        match = /(\d{1,4})([ABC])([12])/.match(parts.first)
        kit = match[1].rjust(4, '0')
        location_letter = match[2]
        sample_number = match[3]
        "K#{kit}-L#{location_letter}-S#{sample_number}"

      # NOTE: K301B1
      # NOTE: X203C1
      # NOTE: 203C1
      elsif /^[KX]?\d{1,4}[ABC][12]$/.match?(sample)
        match = /(\d{1,4})([ABC])([12])/.match(parts.first)
        kit = match[1].rjust(4, '0')
        location_letter = match[2]
        sample_number = match[3]
        "K#{kit}-L#{location_letter}-S#{sample_number}"

      # NOTE: PP301B1
      elsif /^PP\d{1,4}[ABC][12]$/.match?(sample)
        match = /(\d{1,4})([ABC])([12])/.match(parts.first)
        kit = match[1].rjust(4, '0')
        location_letter = match[2]
        sample_number = match[3]
        "K#{kit}-L#{location_letter}-S#{sample_number}"

      # NOTE: K0401.extneg.S135.L001 or X16S_ShrubBlank1
      elsif /(neg)|(blank)/i.match?(sample)
        nil

        # NOTE: X12S_MWWS_H0.54.S54.L001 or X12S_K0723_A1.10.S10.L001
      elsif /^.*?\.\d+\.S\d+\.L\d{3}$/.match?(cell)
        match = /(.*?)\.\d+\.S\d+\.L\d{3}/.match(cell)
        parts = match[1].split('_')
        if parts.length == 3
          "#{parts[1]}-#{parts[2]}"
        else
          "#{parts[0]}-#{parts[1]}"
        end

      elsif /^K\d{1,4}/.match?(sample)
        raise ImportError, "#{sample}: invalid K sample format"
      end
    end
    # rubocop:enable Metrics/MethodLength, Metrics/AbcSize
    # rubocop:enable Metrics/PerceivedComplexity, Metrics/CyclomaticComplexity

    # rubocop:disable Metrics/MethodLength
    def get_extractions_from_headers(
      sample_cells, research_project_id, extraction_type_id
    )
      valid_extractions = {}

      sample_cells.each do |cell|
        next if cell.nil?

        barcode = convert_header_to_barcode(cell)
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
