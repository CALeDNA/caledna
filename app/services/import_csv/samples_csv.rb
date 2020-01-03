# frozen_string_literal: true

module ImportCsv
  module SamplesCsv
    require 'csv'
    include CsvUtils
    include ProcessFileUploads

    def import_csv(file, field_project_id)
      delimiter = delimiter_detector(file)

      # TODO: find a way to deal with image upload
      CSV.foreach(file.path, headers: true, col_sep: delimiter) do |row|
        barcode = row['barcode']
        next if Sample.where(barcode: barcode).present?

        data = create_data_fields(row, barcode, field_project_id)
        Sample.create(data)
      end
    end

    private

    # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
    def create_data_fields(row, barcode, field_project_id)
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
        environmental_features: row['environmental_features'].split(','),
        environmental_settings: row['environmental_settings'].split(','),
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
  end
end
