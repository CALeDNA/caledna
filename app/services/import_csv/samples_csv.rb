# frozen_string_literal: true

module ImportCsv
  module SamplesCsv
    require 'csv'
    include CsvUtils
    include ProcessFileUploads

    # rubocop:disable Metrics/MethodLength
    def import_csv(file, research_project_id)
      delimiter = delimiter_detector(file)

      # TODO: find a way to deal with image upload
      CSV.foreach(file.path, headers: true, col_sep: delimiter) do |row|
        barcode = row['barcode']
        next if Sample.where(barcode: barcode).present?

        data = create_data_fields(row, barcode)
        sample = Sample.create(data)

        extraction_data = {
          sample: sample
        }
        extraction = Extraction.create(extraction_data)

        sourceable_data = {
          sourceable: extraction,
          sample: sample,
          research_project_id: research_project_id
        }
        ResearchProjectSource.create(sourceable_data)
      end
    end
    # rubocop:enable  Metrics/MethodLength

    private

    # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
    def create_data_fields(row, barcode)
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
        field_project_id: FieldProject.find_by(name: 'unknown').id,
        status_cd: 'approved',
        csv_data: row
      }
    end
    # rubocop:enable Metrics/MethodLength, Metrics/AbcSize
  end
end
