# frozen_string_literal: true

namespace :primers_sample do
  require 'csv'

  task import_primers: :environment do
    include ProcessTestResults
    include CsvUtils

    file = File.new( ENV['file'])
    raw_primer = ENV['primer']

    raise 'invalid input' if file.blank? || raw_primer.blank?

    delimiter = delimiter_detector(file)

    puts 'import primers'

    data = CSV.read(file.path, headers: true, col_sep: delimiter)

    first_row = data.first
    sample_cells = first_row.headers[1..first_row.headers.size]

    sample_cells.each do |cell|
      barcode = convert_header_to_barcode(cell)
      puts "#{cell}: #{barcode}"
      next if barcode.blank?

      sample = Sample.find_by(barcode: barcode)
      raise 'invalid sample' if sample.blank?

      primer = Primer.find_by(name: raw_primer)
      raise 'invalid primer' if primer.blank?

      PrimerSample.where(primer: primer, sample: sample).first_or_create
    end
  end
end
