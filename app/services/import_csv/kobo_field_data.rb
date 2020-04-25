# frozen_string_literal: true

module ImportCsv
  module KoboFieldData
    require 'csv'
    include CsvUtils
    include ProcessEdnaResults

    # TODO: find a way to deal with image upload
    # Import csv if all barcodes are not in database. Create new sample for
    # each record.
    # rubocop:disable Metrics/MethodLength
    def import_csv(file, field_project_id)
      data = my_csv_read(file)

      existing_barcodes =
        process_barcodes_for_csv_table(data, 'barcode')[:existing_barcodes]
      if existing_barcodes.present?
        message = "#{existing_barcodes.join(', ')} already in the database"
        return OpenStruct.new(valid?: false, errors: message)
      end

      begin
        collection_date(data.entries.first)
      rescue ArgumentError
        message = 'Date must be in YYYY-MM-DD format.'
        return OpenStruct.new(valid?: false, errors: message)
      end

      create_samples(data, field_project_id)
      OpenStruct.new(valid?: true, errors: nil)
    end
    # rubocop:enable Metrics/MethodLength

    private

    def collection_date(row)
      DateTime.parse("#{row['collection_date']} #{row['collection_time']}")
    end

    def create_samples(data, field_project_id)
      data.entries.each do |row|
        next if row['barcode'].blank?

        sample_data = process_sample(row, field_project_id)
        Sample.create(sample_data)
      end
    end

    # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
    def process_sample(row, field_project_id)
      {
        barcode: row['barcode'],
        collection_date: collection_date(row),
        location: row['location'],
        latitude: row['latitude'],
        longitude: row['longitude'],
        altitude: row['gps_altitude'],
        gps_precision: row['gps_precision'],
        substrate_cd: row['substrate'].downcase,
        habitat_cd: row['habitat'],
        depth_cd: row['sampling_depth'],
        environmental_features:
          convert_comma_separated_string(row['environmental_features']),
        environmental_settings:
          convert_comma_separated_string(row['environmental_settings']),
        field_notes: row['field_notes'],
        country: row['country'],
        country_code: row['country_code'],
        has_permit: row['has_permit'],
        field_project_id: field_project_id,
        status_cd: :approved,
        csv_data: row.to_h
      }
    end
    # rubocop:enable Metrics/AbcSize, Metrics/MethodLength

    def convert_comma_separated_string(string)
      return if string.blank?

      string.split(',').map(&:strip)
    end
  end
end

class ImportError < StandardError
end
