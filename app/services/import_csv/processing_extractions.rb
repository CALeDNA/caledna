# frozen_string_literal: true

module ImportCsv
  # rubocop:disable Metrics/ModuleLength
  module ProcessingExtractions
    require 'csv'
    include ProcessTestResults
    include CsvUtils

    # rubocop:disable Metrics/MethodLength
    def import_csv(file, research_project_id, extraction_type_id)
      delimiter = delimiter_detector(file)

      CSV.foreach(file.path, headers: true, col_sep: delimiter) do |row|
        next if row['Sample Name'].blank?
        next unless processing_started?(row['processor'])

        barcode = form_barcode(row['Sample Name'])
        extraction = find_extraction_from_barcode(barcode, extraction_type_id)

        ImportCsvCreateResearchProjectExtractionJob
          .perform_later(extraction, research_project_id)

        ImportCsvUpdateExtractionDetailsJob
          .perform_later(extraction, extraction_type_id, row.to_json)
      end
    end
    # rubocop:enable Metrics/MethodLength

    def find_researcher(raw_string)
      name = raw_string.strip

      return if name.casecmp('pending').zero?
      researcher = Researcher.find_by(username: name)
      researcher = create_researcher(name) if researcher.blank?
      researcher
    end

    def process_boolean(raw_string)
      string = raw_string.downcase.strip
      if string == 'yes'
        true
      elsif string == 'no'
        false
      end
    end

    def clean_up_hash(hash)
      striped = hash.each { |k, v| hash[k] = v.strip if v.class == String }
      striped.reject { |_, v| v == '' }
    end

    def process_keyword_boolean(raw_string, raw_keyword)
      string = raw_string.downcase.strip
      keyword = raw_keyword.downcase.strip
      if string == keyword || string == 'yes'
        true
      elsif string == 'no'
        false
      end
    end

    # rubocop:disable Metrics/MethodLength
    def convert_date(raw_string)
      return if raw_string.blank?
      return if raw_string.strip.blank?
      return if raw_string.strip == 'pending'

      string = raw_string.downcase.strip
      if string.include?('summer')
        parts = string.split(' ')
        string = "July #{parts.second}"
      elsif /^\w{3}-\d+$/.match?(string)
        string = "1-#{string}"
      end
      Time.parse(string)
    end
    # rubocop:enable Metrics/MethodLength

    # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
    def form_barcode(raw_string)
      raw_barcode = raw_string.strip

      # handles "K0030 B1"
      if raw_barcode.include?(' ')
        parts = raw_barcode.split(' ')
        kit = parts.first
        location_letter = parts.second.split('').first
        sample_number = parts.second.split('').second
        "#{kit}-L#{location_letter}-S#{sample_number}"

      # handles "K0030B1"
      elsif /^K\d{4}\w\d$/.match?(raw_barcode)
        match = /(K\d{4})(\w)(\d)/.match(raw_barcode)
        kit = match[1]
        location_letter = match[2]
        sample_number = match[3]
        "#{kit}-L#{location_letter}-S#{sample_number}"
      else
        raw_barcode
      end
    end
    # rubocop:enable Metrics/AbcSize, Metrics/MethodLength

    private

    def convert_to_array(string, delimiter = ', ')
      string.split(delimiter)
    end

    def processing_started?(processor)
      processor.present?
    end

    def create_researcher(name)
      email = "#{name}#{rand(1000)}@example.com"
      researcher = Researcher.new(username: name, email: email)
      researcher.save(validate: false)
      researcher
    end

    # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
    def format_update_data(row, extraction_type_id)
      {
        extraction_type_id: extraction_type_id,
        sum_taxonomy_example: row['sum.taxonomy example'],
        processor_id: find_researcher(row['processor']).try(:id),
        priority_sequencing: process_boolean(row['priority sequencing']),
        prepub_share: process_boolean(row['prepub share']),
        prepub_share_group: row['prepub share group'],
        prepub_filter_sensitive_info:
          process_boolean(row['prepub filter sensitive info']),
        sra_url: row['SRA url'],
        sra_adder_id: find_researcher(row['SRA adder']).try(:id),
        sra_add_date: convert_date(row['SRA add date']),
        local_fastq_storage_url: row['local fastq storage url'],
        local_fastq_storage_adder_id:
          find_researcher(row['local fastq storage url adder']).try(:id),
        local_fastq_storage_add_date:
          convert_date(row['local fastq storage add date']),
        stat_bio_reps_pooled:
          process_keyword_boolean(row['stat bio reps pooled'], 'pooled'),
        stat_bio_reps_pooled_date:
          convert_date(row['stat bio reps pooled date']),
        loc_bio_reps_pooled: row['loc bio reps pooled'],
        bio_reps_pooled_date: convert_date(row['bio reps pooled date']),
        protocol_bio_reps_pooled: row['protocol bio reps pooled'],
        changes_protocol_bio_reps_pooled:
          row['changes protocol bio reps pooled'],
        stat_dna_extraction:
          process_keyword_boolean(row['stat dna extraction'], 'extracted'),
        stat_dna_extraction_date: convert_date(row['stat dna extraction date']),
        loc_dna_extracts: row['loc dna extracts'],
        dna_extraction_date: convert_date(row['dna extraction date']),
        protocol_dna_extraction: row['protocol dna extraction'],
        changes_protocol_dna_extraction: row['changes protocol dna extraction'],
        metabarcoding_primers: convert_to_array(row['metabarcoding primers']),
        stat_barcoding_pcr_done:
          process_keyword_boolean(row['stat barcoding pcr done'], 'complete'),
        stat_barcoding_pcr_done_date:
          convert_date(row['stat barcoding pcr done date']),
        barcoding_pcr_number_of_replicates:
          row['barcoding pcr number of replicates'],
        reamps_needed: row['reamps needed'],
        stat_barcoding_pcr_pooled:
          process_keyword_boolean(row['stat barcoding pcr pooled'], 'pooled'),
        stat_barcoding_pcr_pooled_date:
          convert_date(row['stat barcoding pcr pooled date']),
        stat_barcoding_pcr_bead_cleaned:
          process_keyword_boolean(row['stat barcoding pcr bead cleaned'],
                                  'cleaned'),
        stat_barcoding_pcr_bead_cleaned_date:
          convert_date(row['stat barcoding pcr bead cleaned date']),
        brand_beads_cd: row['brand beads'],
        cleaned_concentration: row['cleaned concentration'],
        loc_stored: row['loc stored'],
        select_indices_cd: row['select indices'],
        index_1_name: row['index 1'],
        index_2_name: row['index 2'],
        stat_index_pcr_done:
          process_keyword_boolean(row['stat index pcr done'], 'complete'),
        stat_index_pcr_done_date: convert_date(row['stat index pcr done date']),
        stat_index_pcr_bead_cleaned:
          process_keyword_boolean(row['stat index pcr bead cleaned'],
                                  'cleaned'),
        stat_index_pcr_bead_cleaned_date:
          convert_date(row['stat index pcr bead cleaned date']),
        index_brand_beads_cd: row['index brand beads'],
        index_cleaned_concentration: row['index cleaned concentration'],
        index_loc_stored: row['index loc stored'],
        stat_libraries_pooled:
          process_keyword_boolean(row['stat libraries pooled'], 'pooled'),
        stat_libraries_pooled_date:
          convert_date(row['stat libraries pooled date']),
        loc_libraries_pooled: row['loc libraries pooled'],
        stat_sequenced:
          process_keyword_boolean(row['stat sequenced'], 'sequenced'),
        stat_sequenced_date: convert_date(row['stat sequenced date']),
        intended_sequencing_depth_per_barcode:
          row['intended sequencing depth per barcode'],
        sequencing_platform: row['sequencing platform'],
        assoc_field_blank: row['assoc field blank'],
        assoc_extraction_blank: row['assoc extraction blank'],
        assoc_pcr_blank: row['assoc pcr blank'],
        sample_processor_notes: row['sample processor notes'],
        lab_manager_notes: row['lab manager notes'],
        director_notes: row['director notes'],
        status_cd: 'results_completed'
      }
    end
    # rubocop:enable Metrics/AbcSize, Metrics/MethodLength
  end
  # rubocop:enable Metrics/ModuleLength
end
