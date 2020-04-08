# frozen_string_literal: true

module ImportCsv
  module KoboFieldData
    require 'csv'
    include CsvUtils

    # TODO: find a way to deal with image upload
    def import_csv(file, field_project_id)
      delimiter = delimiter_detector(file)
      data = CSV.read(file.path, headers: true, col_sep: delimiter)

      existing_samples = find_existing_samples(data)
      if existing_samples.present?
        message = "#{existing_samples.join(', ')} already in the database"
        return OpenStruct.new(valid?: false, errors: message)
      end

      create_samples(data, field_project_id)
      OpenStruct.new(valid?: true, errors: nil)
    end

    private

    def find_existing_samples(data)
      existing_samples = []
      data.entries.each do |row|
        barcode = row['barcode']
        raise ImportError, 'Barcode missing' if barcode.blank?

        sample = Sample.find_by(barcode: barcode)
        existing_samples << barcode if sample.present?
      end
      existing_samples
    end

    def create_samples(data, field_project_id)
      data.entries.each do |row|
        sample_data = process_sample(row, field_project_id)
        Sample.create(sample_data)
      end
    end

    # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
    def process_sample(row, field_project_id)
      {
        barcode: row['barcode'],
        collection_date:
          DateTime.parse("#{row['collection_date']} #{row['collection_time']}"),
        location: row['location'],
        latitude: row['latitude'],
        longitude: row['longitude'],
        altitude: row['gps_altitude'],
        gps_precision: row['gps_precision'],
        substrate_cd: row['substrate'],
        habitat_cd: row['habitat'],
        depth_cd: row['sampling_depth'],
        environmental_features:
          row['environmental_features'].split(',').map(&:strip),
        environmental_settings:
          row['environmental_settings'].split(',').map(&:strip),
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
  end
end

class ImportError < StandardError
end
