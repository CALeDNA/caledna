# frozen_string_literal: true

module ImportCsv
  module UpdateCoordinates
    include ProcessTestResults

    # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity
    # rubocop:disable Metrics/MethodLength, Metrics/PerceivedComplexity
    def update_coordinates(row)
      barcode = form_barcode(row['MatchName'])
      samples = Sample.where(barcode: barcode)
      return if samples.blank?

      sample = samples.first

      data = {}
      lat = row['Latitude'].to_f
      lon = row['Longitude'].to_f

      if duplicate_barcode?(samples)
        # K0024-LA-S2 K0024-LB-S2 K0024-LC-S1
        # K0166-LA-S1 K0166-LA-S2 K0166-LB-S2 K0166-LC-S2
      elsif sample.status_cd == 'missing_coordinates'
        data[:latitude] = lat
        data[:longitude] = lon
        data[:status_cd] = 'results_completed'
      elsif change_longitude_sign?(sample)
        data[:latitude] = sample.latitude == 1 ? lat : sample.latitude
        data[:longitude] = sample.longitude == 1 ? lon : sample.longitude * -1
      elsif different_coordinates?(sample, lat, lon)
        data[:latitude] = lat
        data[:longitude] = lon
      end
      sample.update(data)
    end
    # rubocop:enable Metrics/AbcSize, Metrics/CyclomaticComplexity
    # rubocop:enable Metrics/MethodLength, Metrics/PerceivedComplexity

    private

    def duplicate_barcode?(samples)
      samples.count > 1
    end

    def change_longitude_sign?(sample)
      sample.longitude.positive?
    end

    def different_coordinates?(sample, lat, lon)
      (sample.latitude - lat).abs > 0.001 ||
        (sample.longitude - lon).abs > 0.001
    end
  end
end
