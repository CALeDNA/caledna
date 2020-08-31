# frozen_string_literal: true

module ImportCsv
  module EdnaResultsAsvs
    require 'csv'
    include ProcessEdnaResults
    include CsvUtils

    # only import csv if all barcodes are in the database. First or create
    # ResearchProjectSource. First or create ASV.
    # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
    def import_csv(file, research_project_id, primer_id)
      results = already_imported?(research_project_id, primer_id)
      return results if results.is_a?(OpenStruct)

      data = my_csv_read(file)
      barcodes = convert_header_row_to_barcodes(data)
      samples = find_samples_from_barcodes(barcodes)

      results = samples_not_in_db?(samples)
      return results if results.is_a?(OpenStruct)

      results = duplicate_barcodes?(data)
      return results if results.is_a?(OpenStruct)

      result_metadata = {
        research_project_id: research_project_id,
        primer_id: primer_id
      }

      # ImportCsvQueueAsvJob calls queue_asv_job
      ImportCsvQueueAsvJob.perform_later(
        data.to_json, barcodes, samples[:valid_data], result_metadata
      )

      OpenStruct.new(valid?: true, errors: nil)
    end
    # rubocop:enable Metrics/MethodLength, Metrics/AbcSize

    # called by ImportCsvQueueAsvJob
    # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
    def queue_asv_job(data_json, barcodes, samples_data, result_metadata)
      data = JSON.parse(data_json)
      data.each do |row|
        next if row.first == 'sum.taxonomy'

        taxonomy_string = row.first
        next if taxonomy_string.blank?
        next if invalid_taxon?(taxonomy_string)

        result_taxon = find_result_taxon_from_string(taxonomy_string)
        if result_taxon.blank? || result_taxon.taxon_id.blank?
          ImportCsvCreateUnmatchedResultJob
            .perform_later(taxonomy_string, result_metadata)
          next
        end

        attributes = result_metadata.merge(taxon_id: result_taxon.taxon_id)
        create_asvs_for_row(row, barcodes, samples_data, attributes)
      end

      update_sample_data(samples_data, result_metadata)
    end
    # rubocop:enable Metrics/MethodLength, Metrics/AbcSize

    def convert_header_row_to_barcodes(data)
      data.first.headers.map do |raw_barcode|
        next if raw_barcode.blank?

        convert_raw_barcode(raw_barcode)
      end
    end

    def find_samples_from_barcodes(barcodes)
      valid_data = {}
      Sample.approved.where(barcode: barcodes.compact).each do |sample|
        valid_data[sample.barcode] = sample.id
      end

      invalid_data = (barcodes.compact - valid_data.keys).uniq

      { invalid_data: invalid_data, valid_data: valid_data }
    end

    private

    def already_imported?(project_id, primer_id)
      records = SamplePrimer.where(research_project_id: project_id)
                            .where(primer_id: primer_id)
      return false if records.blank?

      message = 'The eDNA results for this primer and research project has ' \
        'already been imported.'
      OpenStruct.new(valid?: false, errors: message)
    end

    def samples_not_in_db?(samples)
      return false if samples[:invalid_data].blank?

      message = "#{samples[:invalid_data].join(', ')} not in the database"
      OpenStruct.new(valid?: false, errors: message)
    end

    def duplicate_barcodes?(data)
      duplicate_barcodes = find_duplicate_barcodes(data)
      return false if duplicate_barcodes.blank?

      message = "#{duplicate_barcodes.join(', ')} listed multiple times"
      OpenStruct.new(valid?: false, errors: message)
    end

    def find_duplicate_barcodes(data)
      counts = data.headers.compact.group_by(&:itself).transform_values(&:count)
      counts.select { |_k, v| v > 1 }.keys
    end

    def update_sample_data(samples_data, result_metadata)
      samples_data.each do |_barcode, sample_id|
        attributes = result_metadata.merge(sample_id: sample_id)

        # calls first_or_create_research_project_source
        ImportCsvFirstOrCreateResearchProjSourceJob
          .perform_later(sample_id, 'Sample',
                         result_metadata[:research_project_id])
        ImportCsvUpdateSampleStatusJob.perform_later(sample_id)
        ImportCsvFirstOrCreateSamplePrimerJob.perform_later(attributes)
      end
    end

    def create_asvs_for_row(row, barcodes, samples_data, result_metadata)
      barcodes.each.with_index do |barcode, i|
        next if barcode.blank?

        read_count = row[i].to_i
        next if read_count < 1

        sample_id = samples_data[barcode]

        # calls create_asv
        ImportCsvCreateAsvJob.perform_later(
          result_metadata.merge(sample_id: sample_id, count: read_count,
                                taxonomy_string: row[0])
        )
      end
    end
  end
end

class ImportError < StandardError
end
