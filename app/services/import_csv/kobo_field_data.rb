# frozen_string_literal: true

module ImportCsv
  module KoboFieldData
    require 'csv'
    include CsvUtils
    include ProcessEdnaResults

    # TODO: find a way to deal with image upload
    # Import csv if all barcodes are not in database. Create new sample for
    # each record.
    # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
    def import_csv(file, field_project_id)
      data = my_csv_read(file)

      barcodes = process_barcode_column(data, 'barcode')
      existing_barcodes = barcodes[:existing_barcodes]
      if existing_barcodes.present?
        message = "#{existing_barcodes.join(', ')} already in the database"
        return OpenStruct.new(valid?: false, errors: message)
      end

      duplicate_barcodes = barcodes[:duplicate_barcodes]
      if duplicate_barcodes.present?
        message = "#{duplicate_barcodes.join(', ')} listed multiple times"
        return OpenStruct.new(valid?: false, errors: message)
      end

      begin
        collection_date(data.entries.first)
      rescue ArgumentError
        message = 'Date must be in YYYY-MM-DD, YYYY/MM/DD, MM-DD-YYYY, or ' \
          'MM/DD/YYYY format.'
        return OpenStruct.new(valid?: false, errors: message)
      end

      create_samples(data, field_project_id)
      OpenStruct.new(valid?: true, errors: nil)
    end
    # rubocop:enable Metrics/MethodLength, Metrics/AbcSize

    # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
    def process_sample(row, field_project_id)
      barcode = convert_raw_barcode(row['barcode'])
      {
        barcode: barcode,
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
        csv_data: row.to_h.reject { |k, _v| k.blank? }
      }
    end
    # rubocop:enable Metrics/AbcSize, Metrics/MethodLength

    private

    def format_date_string(date_string)
      # converts 01-31-2000 to 2000-01-31
      if /\d\d-\d\d-\d\d\d\d/.match?(date_string)
        new_date = /(\d\d)-(\d\d)-(\d\d\d\d)/.match(date_string)
        date_string = "#{new_date[3]}-#{new_date[1]}-#{new_date[2]}"
      end

      # converts 01/31/2000 to 2000-01-31
      if /\d\d\/\d\d\/\d\d\d\d/.match?(date_string)
        new_date = /(\d\d)\/(\d\d)\/(\d\d\d\d)/.match(date_string)
        date_string = "#{new_date[3]}-#{new_date[1]}-#{new_date[2]}"
      end
      date_string
    end

    def collection_date(row)
      date = format_date_string(row['collection_date'])
      raw_date_time = "#{date} #{row['collection_time']}"
      begin
        DateTime.parse(raw_date_time)
      rescue ArgumentError
        date = Date.strptime(raw_date_time, '%m/%d/%Y %H:%M')
        date.strftime('%Y-%m%-%d %H:%M')
      end
    end

    def create_samples(data, field_project_id)
      data.entries.each do |row|
        next if row['barcode'].blank?

        clean_row = row.to_h.reject { |k, _v| k.blank? }
        sample_data = process_sample(clean_row, field_project_id)

        Sample.create(sample_data)
      end
    end

    def convert_comma_separated_string(string)
      return if string.blank?

      string.split(',').map(&:strip)
    end
  end
end

class ImportError < StandardError
end
