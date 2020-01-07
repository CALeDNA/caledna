# frozen_string_literal: true

module ImportCsv
  module SamplesCsv
    require 'csv'
    include CsvUtils
    include ProcessFileUploads

    def import_csv(file, field_project_id)
      delimiter = delimiter_detector(file)

      # TODO: find a way to deal with image upload
      invalid_barcodes = find_invalid_barcodes(file, delimiter)
      if invalid_barcodes.present?
        message = "#{invalid_barcodes.join(', ')} already exists"
        return OpenStruct.new(valid?: false, errors: message)
      end

      CSV.foreach(file.path, headers: true, col_sep: delimiter) do |row|
        data = create_data_fields(row, field_project_id)
        Sample.create(data)
      end
      OpenStruct.new(valid?: true, errors: nil)
    end

    private

    def find_invalid_barcodes(file, delimiter)
      invalid_barcodes = []
      CSV.foreach(file.path, headers: true, col_sep: delimiter) do |row|
        barcode = row['barcode']
        sample = Sample.approved.find_by(barcode: barcode)
        invalid_barcodes << barcode if sample.present?
      end
      invalid_barcodes
    end

    # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
    def create_data_fields(row, field_project_id)
      barcode = row['barcode']
      date =
        DateTime.parse("#{row['collection_date']}T#{row['collection_time']}")
      {
        barcode: barcode,
        collection_date: date,
        submission_date: date,
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
        status_cd: 'approved',
        csv_data: row.to_h
      }
    end
    # rubocop:enable Metrics/MethodLength, Metrics/AbcSize

    def convert_comma_separated_string(string)
      string.split(',').map(&:strip)
    end
  end
end
