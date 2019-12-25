# frozen_string_literal: true

namespace :samples do
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
