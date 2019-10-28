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
        barcode = row['sample_id']
        next if Sample.where(barcode: barcode).present?

        sample = Sample.create(create_data_fields(row, barcode))

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
      date = DateTime.parse("#{row['sampling_date']}T#{row['sampling_time']}")
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
        habitat: row['habitat'],
        depth: row['sampling_depth'],
        environmental_features: row['environmental_features'],
        environmental_settings: row['environmental_settings'],
        field_notes: row['field_notes'],
        field_project_id: FieldProject.find_by(name: 'unknown').id,
        status_cd: 'approved',
        csv_data: row
      }
    end
    # rubocop:enable Metrics/MethodLength, Metrics/AbcSize
  end
end
