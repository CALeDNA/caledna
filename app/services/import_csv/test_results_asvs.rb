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
        # NOTE: always use phylum taxon string to match older cal_taxon
        # than only have phylum_taxonomy_string
        string = if phylum_taxonomy_string?(taxonomy_string)
                   taxonomy_string
                 else
                   convert_superkingdom_taxonomy_string(taxonomy_string)
                 end

        cal_taxon = find_cal_taxon_from_string(string)
        next if cal_taxon.blank?
        create_asvs(row, sample_cells, extractions, cal_taxon)
      end
    end
    # rubocop:enable Metrics/MethodLength, Metrics/AbcSize

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
      elsif /^[KX]?\d{1,4}[ABC][12]$/.match?(sample)
        match = /(\d{1,4})([ABC])([12])/.match(parts.first)
        kit = match[1].rjust(4, '0')
        location_letter = match[2]
        sample_number = match[3]
        "K#{kit}-L#{location_letter}-S#{sample_number}"

      # NOTE: K0401.extneg.S135.L001 or X16S_ShrubBlank1
      elsif /(neg)|(blank)/i.match?(sample)
        nil

      elsif /^K\d{1,4}/.match?(sample)
        raise ImportError, "#{sample}: invalid sample format"
      end
    end
    # rubocop:enable Metrics/MethodLength, Metrics/AbcSize
    # rubocop:enable Metrics/PerceivedComplexity, Metrics/CyclomaticComplexity

    private

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

    def create_asvs(row, sample_cells, extractions, cal_taxon)
      sample_cells.each do |cell|
        count = row[cell].to_i
        next if count < 1

        extraction = extractions[cell]
        ImportCsvCreateAsvJob.perform_later(cell, extraction, cal_taxon, count)
      end
    end
  end
end

class ImportError < StandardError
end
