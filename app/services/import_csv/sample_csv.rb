# frozen_string_literal: true

module ImportCsv
  module SampleCsv
    require 'csv'

    # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
    def import_csv(file, research_project_id)
      CSV.foreach(file.path, headers: true) do |row|
        barcode = "#{row['Kit']}-#{row['Tubes']}"
        update_data = update_data_fields(row)
        create_data = create_data_fields(row, barcode)

        # TODO: find better way to handle cases with duplicate barcodes
        sample = Sample.where(barcode: barcode).first
        if sample.present?
          sample.update(update_data)
        else
          sample = Sample.create(create_data.merge(update_data))
        end

        extraction_data = {
          sample: sample
        }
        extraction = Extraction.where(extraction_data).first_or_create

        research_extraction_data = {
          extraction: extraction,
          research_project_id: research_project_id
        }
        ResearchProjectExtraction.where(research_extraction_data)
                                 .first_or_create
      end
    end
    # rubocop:enable Metrics/AbcSize, Metrics/MethodLength

    def update_data_fields(row)
      {
        elevatr_altitude: row['Elevatr Altitude (meters)'],
        # TODO: decide on what status to use
        # status_cd: 'submitted',
      }
    end

    # rubocop:disable Metrics/MethodLength
    def create_data_fields(row, barcode)
      {
        barcode: barcode,
        latitude: row['Latitude'],
        longitude: row['Longitude'],
        altitude: row['Altitude'],
        gps_precision: row['GPS Precision'],
        location: row['Reserve'],
        field_notes: row['Notes'],
        substrate_cd: row['Substrate'],
        field_data_project_id: FieldDataProject.find_by(name: 'unknown').id
      }
    end
    # rubocop:enable Metrics/MethodLength
  end
end
