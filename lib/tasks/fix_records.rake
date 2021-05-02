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
    path = './lib/tasks/data/fix_records/samples_rollback.csv'
    CSV.foreach(path, headers: true, col_sep: ',') do |row|
      id = row['id']
      sample = Sample.where(id: id).where(longitude: -116.313099).first

      next if sample.blank?

      puts id
      attributes = row.to_h.except('id')
      attributes['kobo_data'] = JSON.parse(attributes['kobo_data'])
      attributes['csv_data'] = JSON.parse(attributes['csv_data'])
      attributes['metadata'] = JSON.parse(attributes['metadata'])
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

  task fix_malformed_metadata: :environment do
    samples = Sample.where("metadata != '{}'")
    samples.each do |sample|
      puts sample.id
      if sample.metadata == '{}'
        sample.metadata = {}
        sample.save
      elsif sample.metadata.is_a? String
        sample.metadata = JSON.parse(sample.metadata)
        sample.save
      end
    end
  end

  task fix_malformed_kobo_data: :environment do
    samples = Sample.where("kobo_data = '\"{}\"'")
    samples.each do |sample|
      puts sample.id
      sample.kobo_data = {}
      sample.save
    end
  end

  desc 'When working on 1000 samples, I noticed the sample count in Kobo ' \
    'did not match the site field project sample count.'
  task check_samples_not_in_kobo: :environment do
    kit1 = 'What is your kit number? (e.g. K0021)'
    location1 = 'Which location letter is on your barcodes in your sample ' \
      'bag? LA, LB, or LC?'
    site1 = 'Which site number is on your barcodes? S1 or S2?'

    kit2 = ' The three tubes have a kit number (e.g. K0501) and letters and ' \
      'numbers after a dash (e.g. -A1). Enter the KIT number beginning with K.'
    letter2 = 'Select the match for the letters and numbers after the dash ' \
      'on your tubes.'

    path = './lib/tasks/data/fix_records/'

    files = [
      {
        file: 'EEB87_CALeDNA_2018_-_2020-07-04-12-26-32.csv',
        id: 16,
        kit_column: kit1,
        location_column: location1,
        site_column: site1,
        version: 1
      },
      {
        file: 'CALeDNA_NovDec2019_bioblitzes_-_2020-07-04-12-24-29.csv',
        id: 62,
        kit_column: kit2,
        letter_column: letter2,
        version: 2
      }
    ]

    index = 0
    file = files[index][:file]
    field_project_id = files[index][:id]
    kit_column = files[index][:kit_column]
    letter_column = files[index][:letter_column]
    location_column = files[index][:location_column]
    site_column = files[index][:site_column]
    version = files[index][:version]
    full_path = "#{path}#{file}"

    barcodes = Sample.where(field_project_id: field_project_id).pluck(:barcode)
    in_db = []
    not_in_db = []
    not_in_kobo = []

    CSV.foreach(full_path, headers: true, col_sep: ';') do |row|
      next if row[kit_column].blank?

      kit = row[kit_column].upcase.strip.tr('O', '0').tr(' ', '')
                           .split('-').first

      if version == 1
        location = row[location_column]&.strip
        site = row[site_column]&.strip

        # handles K0000LAS1
        if /^K\d{1,4}L[ABC]S[12]$/i.match?(kit)
          match = /(K\d{1,4})(L[ABC])(S[12])/i.match(kit)
          kit = match[1]
          location = match[2]
          site = match[3]
        end

        barcode = "#{kit}-#{location}-#{site}"
      else
        if kit.length != 5
          nums = kit.tr('K', '')
          kit = 'K' + nums.rjust(4, '0')
        end

        letter = row[letter_column]&.strip
        barcode = "#{kit}-#{letter}"
      end

      if barcodes.include?(barcode)
        in_db << barcode
      else
        not_in_db << barcode
      end
    end
    not_in_kobo << barcodes - in_db

    puts 'not_in_db'
    puts not_in_db
    puts

    puts 'not_in_kobo'
    puts not_in_kobo
  end

  task update_barcodes_after_1000_samples: :environment do
    sqls = [
      "UPDATE samples SET barcode = 'K0572-B2' WHERE barcode = 'K572-B2';",
      "UPDATE samples SET barcode = 'K0835-A1' WHERE barcode = 'K835-A1';",
      "UPDATE samples SET barcode = 'K0759-E4' WHERE barcode = 'K759-E4';",
      "DELETE FROM samples WHERE (\"barcode\" ILIKE E'%\\\\_%')" \
        ' AND ("field_project_id" = 62);',
      "UPDATE samples SET barcode = 'K0489-LB-S2' WHERE barcode = " \
        "'K0489 LB S2-LA LB-S2';",
      "UPDATE samples set status_cd = 'approved' where " \
        "status_cd ='processing_sample';"
    ]

    sqls.each do |sql|
      ActiveRecord::Base.connection.exec_query(sql)
    end
  end

  def conn
    ActiveRecord::Base.connection
  end
end
