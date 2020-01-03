# frozen_string_literal: true

module ImportCsv
  module KoboSamplesMetadata
    require 'csv'
    # include ProcessEdnaResults
    include CsvUtils

    def import_csv(file)
      delimiter = delimiter_detector(file)

      invaild_samples = find_invalid_samples(file, delimiter)
      if invaild_samples.present?
        message = "#{invaild_samples.join(', ')} not in the database"
        return OpenStruct.new(valid?: false, errors: message)
      end

      update_samples(file, delimiter)
      OpenStruct.new(valid?: true, errors: nil)
    end

    private

    def find_invalid_samples(file, delimiter)
      invalid_samples = []
      CSV.foreach(file.path, headers: true, col_sep: delimiter) do |row|
        barcode = row['barcode']
        next if barcode.blank?

        sample = Sample.approved.find_by(barcode: barcode)
        invalid_samples << barcode if sample.blank?
      end
      invalid_samples
    end

    def update_samples(file, delimiter)
      CSV.foreach(file.path, headers: true, col_sep: delimiter) do |row|
        update_sample(row)
      end
    end

    def update_sample(row)
      barcode = row['barcode']
      return if barcode.blank?

      hash = row.to_hash.reject do |k, _v|
        k == 'barcode' || k.blank?
      end

      sample = Sample.approved.find_by(barcode: barcode)
      sample.metadata = sample.metadata.merge(hash)
      sample.save
    end
  end
end

class ImportError < StandardError
end
