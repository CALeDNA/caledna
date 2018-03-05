# frozen_string_literal: true

module ImportCsv
  module SampleCsv
    require 'csv'

    # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
    def import_sample_csv(file)
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
          sample: sample,
          extraction_type: ExtractionType.first
        }
        Extraction.where(extraction_data).first_or_create
      end
    end
    # rubocop:enable Metrics/AbcSize, Metrics/MethodLength

    def update_data_fields(row)
      {
        elevatr_altitude: row['Elevatr Altitude (meters)'],
        primer_16s: row['16S'],
        primer_18s: row['18S'],
        primer_cO1: row['CO1'],
        primer_fits: row['FITS'],
        primer_pits: row['PITS'],
        status_cd: 'results_completed',
        csv_data: row.to_h
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
        notes: row['Notes'],
        substrate_cd: row['Substrate'],
        field_data_project_id: FieldDataProject.find_by(name: 'unknown').id
      }
    end
    # rubocop:enable Metrics/MethodLength
  end
end
