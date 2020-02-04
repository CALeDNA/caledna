# frozen_string_literal: true

module KoboApi
  module Process
    include ProcessFileUploads

    def import_kobo_projects(hash_payload)
      results = hash_payload.map do |project_data|
        next if project_ids.include?(project_data['id'])
        save_project_data(project_data)
      end
      results.compact.all? { |r| r }
    end

    def import_kobo_samples(project_id, kobo_id, hash_payload)
      counter = 0
      hash_payload.map do |sample_data|
        next if kobo_sample_ids.include?(sample_data['_id'])
        counter += 1
        ImportKoboSampleJob.perform_later(project_id, kobo_id, sample_data)
      end
      counter
    end

    def save_project_data(hash_payload)
      data = OpenStruct.new(hash_payload)
      project = ::FieldProject.new(
        name: data.title,
        description: data.description,
        kobo_id: data.id,
        kobo_payload: hash_payload,
        last_import_date: Time.zone.now
      )

      project.save
    end

    def save_sample_data(field_project_id, kobo_id, hash_payload)
      case kobo_id
      when 95_481, 87_534, 95_664, 83_937
        process_multi_samples(field_project_id, hash_payload)
      when 136_577, 130_560, 138_676, 170_620
        process_single_sample_v1(field_project_id, hash_payload)
      else
        process_single_sample_v2(field_project_id, hash_payload)
      end
    end

    # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
    def save_photos(sample_id, hash_payload)
      data = OpenStruct.new(hash_payload)

      photos_data = data._attachments
      return if photos_data.blank?

      photos_data.map do |photo_data|
        data = OpenStruct.new(photo_data)

        url = "#{ENV.fetch('KOBO_MEDIA_URL')}#{data.filename}"
        filename = data.filename.split('/').last
        kobo_photo = ::KoboPhoto.new(
          file_name: filename,
          source_url: url,
          kobo_payload: data,
          sample_id: sample_id
        )

        kobo_photo.save
        fetch_kobo_file_and_attach_to(url, kobo_photo.photo)
      end
      # rubocop:enable Metrics/MethodLength, Metrics/AbcSize
    end

    private

    def project_ids
      FieldProject.pluck(:kobo_id)
    end

    def clean_kit_number(kit_number)
      clean_kit_number = kit_number
      clean_kit_number.try(:upcase)
    end

    def kobo_sample_ids
      Sample.pluck(:kobo_id)
    end

    def non_kobo_barcodes
      Sample.where(kobo_id: nil).pluck(:barcode)
    end

    def project(kobo_id)
      Project.find_by(kobo_id: kobo_id)
    end

    # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
    def sample_prefixes
      [
        { gps: 'groupA/A1/A1gps', other: 'groupA/A1/A1', tube: 'LA-S1' },
        { gps: 'groupA/A2/A2gps', other: 'groupA/A2/A2', tube: 'LA-S2' },
        { gps: 'groupB/B1/barcodesB1/B1gps', other: 'groupB/B1/B1',
          tube: 'LB-S1' },
        { gps: 'groupB/B2/barcodesB2/B2gps', other: 'groupB/B2/B2',
          tube: 'LB-S2' },
        { gps: 'locC1/C1/barcodesC1/C1gps', other: 'locC1/C1/C1',
          tube: 'LC-S1' },
        { gps: 'locC1/C2/barcodesC2/C2gps', other: 'locC1/C2/C2',
          tube: 'LC-S2' }
      ]
    end

    def format_barcode(data)
      kit_number = clean_kit_number(data.What_is_your_kit_number_e_g_K0021)
      if data.Which_location_lette_codes_LA_LB_or_LC.present?
        location_letter =
          data.Which_location_lette_codes_LA_LB_or_LC.try(:upcase)
        site_number = data.You_re_at_your_first_r_barcodes_S1_or_S2.try(:upcase)
        barcode = "#{kit_number}-#{location_letter}-#{site_number}"
      else
        e_data = data.Select_the_match_for_e_dash_on_your_tubes.try(:upcase)
        barcode = "#{kit_number}-#{e_data}"
      end
      barcode
    end

    def process_single_sample_v1(field_project_id, hash_payload)
      data = OpenStruct.new(hash_payload)
      data.barcode = format_barcode(data)
      data.gps = data.Get_the_GPS_Location_e_this_more_accurate
      data.substrate = data.What_type_of_substrate_did_you
      data.field_notes = [
        data.Notes_on_recent_mana_the_sample_location,
        data._Optional_Regarding_rns_to_share_with_us
      ].compact.join(' ')
      data.location = [
        data.Where_are_you_A_UC_serve_or_in_Yosemite,
        data.If_at_a_UC_Natural_R_ve_select_which_one, # UCNR
        data.Location, # CVMSHCP
        data.If_at_LA_River_water_which_body_of_water # LA River
      ].compact.join(' ')
      data.field_project_id = field_project_id

      sample = save_sample(data, hash_payload)
      save_photos(sample.id, hash_payload)
    end

    def process_single_sample_v2(field_project_id, hash_payload)
      data = OpenStruct.new(hash_payload)
      data.barcode = format_barcode(data)
      data.gps = data.Get_the_GPS_Location_e_this_more_accurate
      data.substrate = data.What_type_of_substrate_did_you
      data.field_notes = data._Optional_Regarding_rns_to_share_with_us
      data.field_project_id = field_project_id

      data.location = [
        clean_kobo_field(data.Where_are_you_A_UC_serve_or_in_Yosemite,
                         KoboValues::LOCATION_HASH),
        clean_kobo_field(data.If_at_a_UC_Natural_R_ve_select_which_one,
                         KoboValues::UCNR_HASH),
        clean_kobo_field(data.Location,
                         KoboValues::CVMSHCP_HASH),
        clean_kobo_field(data.If_at_LA_River_water_which_body_of_water,
                         KoboValues::LA_RIVER_HASH)
      ].compact.join('; ')
      data.habitat = clean_kobo_field(
        data._optional_Describe_ou_are_sampling_from,
        KoboValues::HABITAT_HASH
      )
      data.depth = clean_kobo_field(
        data._optional_What_dept_re_your_samples_from,
        KoboValues::DEPTH_HASH
      )

      features = []
      features << clean_kobo_multi_field(
        data.Choose_from_common_environment,
        KoboValues::ENVIRONMENTAL_FEATURES_HASH
      )
      features << clean_kobo_multi_field(
        data.environment_feature, KoboValues::ENVIRONMENTAL_FEATURES_HASH
      )
      features << data.If_other_describe_t_nvironmental_feature
      data.environmental_features = features.flatten.compact

      data.environmental_settings =
        clean_kobo_multi_field(data.Describe_the_environ_tions_from_this_list,
                               KoboValues::ENVIRONMENTAL_SETTINGS_HASH)

      sample = save_sample(data, hash_payload)
      save_photos(sample.id, hash_payload)
    end

    def process_multi_samples(field_project_id, hash_payload)
      data = OpenStruct.new(hash_payload)
      kit_number = clean_kit_number(data.kit || '')

      sample_prefixes.each do |prefix|
        data.barcode = "#{kit_number}-#{prefix[:tube]}"
        data.gps = data.send(prefix[:gps]) || ''
        data.substrate = data.send("#{prefix[:other]}SS")
        data.field_notes = data.send("#{prefix[:other]}comments")
        data.location =
          [data.somewhere, data.where, data.reserves].compact.join('; ')
        data.field_project_id = field_project_id

        sample = save_sample(data, hash_payload)
        photo_payload = find_photos(prefix[:other], hash_payload)
        save_photos(sample.id, _attachments: photo_payload)
      end
    end

    def find_photos(prefix, hash_payload)
      photo_filenames = hash_payload.select do |key|
        key.starts_with?("#{prefix}picgroup")
      end.values

      photo_filenames.flat_map do |filename|
        hash_payload['_attachments'].select do |attachment|
          attachment['filename'].ends_with?(filename)
        end
      end
    end

    def save_sample(data, hash_payload)
      sample_data = {
        field_project_id: data.field_project_id,
        kobo_id: data._id,
        kobo_data: hash_payload,
        collection_date: data.Enter_the_sampling_date_and_time,
        submission_date: data._submission_time,
        location: data.location,
        substrate: data.substrate,
        field_notes: data.field_notes,
        habitat: data.habitat,
        depth: data.depth,
        environmental_features: data.environmental_features,
        environmental_settings: data.environmental_settings
      }

      if data.gps.present?
        sample_data = sample_data.merge(
          latitude: data.gps.split.first,
          longitude: data.gps.split.second,
          altitude: data.gps.split.third,
          gps_precision: data.gps.split.fourth
        )
      end

      if non_kobo_barcodes.include?(data.barcode)
        ::Sample.update(sample_data).where(barcode: data.barcode)
      else
        sample_data[:status] = :submitted
        sample_data[:barcode] = data.barcode
        ::Sample.create(sample_data)
      end
    end

    def clean_kobo_field(kobo_values, field_hash)
      return if kobo_values.blank?

      field_hash[kobo_values] || kobo_values
    end

    def clean_kobo_multi_field(kobo_values, field_hash)
      return if kobo_values.blank?

      raw_values = kobo_values.split(' ')
      raw_values.map do |value|
        field_hash[value] || value
      end
    end
    # rubocop:enable Metrics/MethodLength, Metrics/AbcSize
  end
end

# PROJECT = {
#   '98565': ['Yosemite', '?', '0 records'],
#   '154164': ['Mojave_CALeDNA / CALeDNA Mojave Bioblitz 1', '?', '0 records'],

#   '95481': ['CALeDNA_test20170418 / CALeDNA Coastal Bioblitz 1',
#   'MULTI_SAMPLE_FIELDS_A', '5 records'],
#   '87534': ['Welcome to CALeDNA! / CALeDNA Spring Bioblitz 1',
#   'MULTI_SAMPLE_FIELDS_A', '50 records'],
#   '95664': ['CALeDNA_test20170419 / CALeDNA Bioblitz Spring and Fall 1',
#   'MULTI_SAMPLE_FIELDS_A', '40 records'],
#   '83937': ['CALeDNA_iOS / Pillar_Point_1', 'MULTI_SAMPLE_FIELDS_A',
#   '12 records'],

#   '138676': ['CALeDNA mountains / CALeDNA Mountain Bioblitz 1',
#   'SINGLE_SAMPLE_FIELDS_v1', '24 records'],
#   '130560': ['Sedgwick / CALeDNA Fall Bioblitz 1',
#   'SINGLE_SAMPLE_FIELDS_v1', '173 records'],
#   '136577': ['CALeDNA coastal / CALeDNA Coastal Bioblitz 2',
#   'SINGLE_SAMPLE_FIELDS_v1', '86 records'],
#   '170620': ['younger lagoon', 'SINGLE_SAMPLE_FIELDS_v1', '86 records'],

#   '168570': ['CALeDNA 2018', 'MULTI_SAMPLE_FIELDS_v2', '40 records'],
# }
