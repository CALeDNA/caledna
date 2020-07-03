# frozen_string_literal: true

namespace :fix_records do
  # https://rubyinrails.com/2019/07/12/postgres-reset-sequence-to-max-id-in-rails/
  task reset_sequence: :environment do
    conn.tables.each do |table|
      puts table
      conn.reset_pk_sequence!(table)
    end
  end

  task reset_samples_for_bad_kobo_import: :environment do
    path = './lib/tasks/data/samples_rollback.csv'
    CSV.foreach(path, headers: true, col_sep: ',') do |row|
      id = row['id']
      sample = Sample.where(id: id).where(longitude: -116.313099).first

      next if sample.blank?

      puts id
      attributes = row.to_h.except('id')
      attributes['kobo_data'] = JSON.parse(attributes['kobo_data'])
      sample.update(attributes)
    end
  end

  task fix_malformed_csv_data: :environment do
    samples = Sample.where("csv_data != '{}'")
    samples.each do |sample|
      puts sample.id
      if sample.csv_data == '{}'
        sample.csv_data = {}
        sample.save
      elsif sample.csv_data.is_a? String
        sample.csv_data = JSON.parse(sample.csv_data)
        sample.save
      end
    end
  end
end
