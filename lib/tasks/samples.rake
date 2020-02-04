# frozen_string_literal: true

namespace :samples do
  # In late October 2019, we started saving Kobo Photos to AWS. Discovered in
  # Feb 2020 that saving to AWS was broken, so need to redo KoboPhotos.
  task fix_broken_photo_import: :environment do
    include KoboApi::Process

    date = '2019-10-30'
    samples = Sample.where("created_at > '#{date}'")
    ids = samples.pluck(:id)

    KoboPhoto.where(sample_id: ids).destroy_all

    samples.each do |sample|
      puts sample.id
      save_photos(sample.id, sample.kobo_data)
    end
  end

  task delete_duplicate_submitted_samples: :environment do
    puts 'begin delete_duplicate_samples...'
    dup_samples = Sample.where(status_cd: 'submitted')
                        .group(:kobo_id)
                        .group(:kobo_data)
                        .having('count(*) > 1')

    kobo_ids = dup_samples.pluck(:kobo_id)
    kobo_ids.each do |id|
      puts id
      samples = Sample.where(kobo_id: id)
      count = samples.count

      extra_samples = samples.limit(count - 1)
      extra_samples.each do |sample|
        KoboPhoto.where(sample_id: sample.id).destroy_all
        sample.destroy
      end
    end
  end

  task import_coordinates: :environment do
    require 'csv'
    require_relative '../../app/services/import_csv/update_coordinates'
    include ImportCsv::UpdateCoordinates

    path = "#{Rails.root}/public/seed/sample_coords.csv"

    CSV.foreach(path, headers: true) do |row|
      update_coordinates(row)
    end
  end

  task clean_kobo_data: :environment do
    def clean_kobo_field(sample, key, field_hash)
      raw_values = sample.kobo_data[key].split(' ')
      raw_values.map do |value|
        field_hash[value] || value
      end
    end

    Sample.all.each do |sample|
      puts sample.barcode

      key = 'Describe_the_environ_tions_from_this_list'
      field_hash = KoboValues::ENVIRONMENTAL_SETTINGS_HASH
      if sample.kobo_data[key]
        clean_values = clean_kobo_field(sample, key, field_hash)
        sample.environmental_settings = clean_values
      end

      features = []
      key = 'Choose_from_common_environment'
      field_hash = KoboValues::ENVIRONMENTAL_FEATURES_HASH
      if sample.kobo_data[key]
        clean_values = clean_kobo_field(sample, key, field_hash)
        features << clean_values
      end

      key = 'environment_feature'
      field_hash = KoboValues::ENVIRONMENTAL_FEATURES_HASH
      if sample.kobo_data[key]
        clean_values = clean_kobo_field(sample, key, field_hash)
        features << clean_values
      end

      key = 'If_other_describe_t_nvironmental_feature'
      features << sample.kobo_data[key] if sample.kobo_data[key]
      sample.environmental_features = features.flatten

      key = '_optional_What_dept_re_your_samples_from'
      field_hash = KoboValues::DEPTH_HASH
      if sample.kobo_data[key]
        clean_values = clean_kobo_field(sample, key, field_hash).first
        sample.depth = clean_values
      end

      key = '_optional_Describe_ou_are_sampling_from'
      field_hash = KoboValues::HABITAT_HASH
      if sample.kobo_data[key]
        clean_values = clean_kobo_field(sample, key, field_hash).first
        sample.habitat = clean_values
      end

      locations = []
      key = 'Where_are_you_A_UC_serve_or_in_Yosemite'
      field_hash = KoboValues::LOCATION_HASH
      if sample.kobo_data[key]
        clean_values = clean_kobo_field(sample, key, field_hash)
        locations << clean_values
      end

      key = 'If_at_a_UC_Natural_R_ve_select_which_one'
      field_hash = KoboValues::UCNR_HASH
      if sample.kobo_data[key]
        clean_values = clean_kobo_field(sample, key, field_hash).first
        locations << clean_values
      end

      key = 'Location'
      field_hash = KoboValues::CVMSHCP_HASH
      if sample.kobo_data[key]
        clean_values = clean_kobo_field(sample, key, field_hash).first
        locations << clean_values
      end

      key = 'If_at_LA_River_water_which_body_of_water'
      field_hash = KoboValues::LA_RIVER_HASH
      if sample.kobo_data[key]
        clean_values = clean_kobo_field(sample, key, field_hash).first
        locations << clean_values
      end

      sample.location = locations.flatten
                                 .reject { |i| i.start_with?('AUTOMATIC') }
                                 .join('; ')

      sample.save
    end
  end
end
