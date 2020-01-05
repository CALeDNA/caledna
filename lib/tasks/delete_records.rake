# frozen_string_literal: true

namespace :delete_records do
  # bin/rake delete_records:samples[<barcode>]
  desc 'delete a sample and related records'
  task :samples, [:barcode] => :environment do |_t, args|
    barcode = args[:barcode]
    raise StandardError, 'must pass in barcode' if barcode.blank?

    sample = Sample.find_by(barcode: barcode)
    raise StandardError, "No samples for #{barcode}" if sample.blank?

    sample_id = sample.id
    puts "deleting records for #{barcode}, #{sample_id}"

    ActiveRecord::Base.transaction do
      ResearchProjectSource.where(sample_id: sample_id).destroy_all
      KoboPhoto.where(sample_id: sample_id).destroy_all
      Asv.where(sample_id: sample_id).destroy_all
      sample.destroy
    end
  end
end
