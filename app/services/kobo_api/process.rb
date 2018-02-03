# frozen_string_literal: true

module KoboApi
  class Process
    def self.import_projects(hash_payload)
      results = hash_payload.map do |project_data|
        next if project_ids.include?(project_data['id'])
        save_project(project_data)
      end
      results.compact.all? { |r| r }
    end

    def self.save_project(hash_payload)
      data = OpenStruct.new(hash_payload)
      project = ::Project.new(
        name: data.title,
        description: data.description,
        kobo_name: data.title,
        kobo_id: data.id,
        kobo_payload: hash_payload,
        last_import_date: Time.zone.now
      )

      project.save
    end

    def self.project_ids
      Project.pluck(:kobo_id)
    end

    def self.import_samples(project_id, hash_payload)
      results = hash_payload.map do |sample_data|
        next if sample_ids.include?(sample_data['_id'])
        save_sample(project_id, sample_data)
        save_photos(Sample.last.id, sample_data)
      end
      results.compact.all? { |r| r }
    end

    # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
    def self.save_sample(project_id, hash_payload)
      data = OpenStruct.new(hash_payload)

      kit_number =
        (data.What_is_your_kit_number_e_g_K0021 || data.kit).try(:upcase)
      location_letter = data.Which_location_lette_codes_LA_LB_or_LC.try(:upcase)
      site_number = data.You_re_at_your_first_r_barcodes_S1_or_S2.try(:upcase)

      # rubocop:disable Style/ConditionalAssignment
      if data.kit
        bar_code = data.kit
      else
        bar_code = "#{kit_number}-#{location_letter}-#{site_number}"
      end
      # rubocop:enable Style/ConditionalAssignment

      sample = ::Sample.new(
        project_id: project_id,
        kobo_id: data._id,
        latitude: data._geolocation.first,
        longitude: data._geolocation.second,
        collection_date: data.Enter_the_sampling_date_and_time,
        submission_date: data._submission_time,
        bar_code: bar_code,
        kobo_data: hash_payload
      )

      sample.save
    end
    # rubocop:enable Metrics/MethodLength, Metrics/AbcSize

    # rubocop:disable Metrics/MethodLength
    def self.save_photos(sample_id, hash_payload)
      data = OpenStruct.new(hash_payload)

      photos_data = data._attachments
      photos_data.each do |photo_data|
        data = OpenStruct.new(photo_data)

        filename = data.filename.split('/').last
        photo = ::Photo.new(
          file_name: filename,
          source_url: "#{ENV.fetch('KOBO_MEDIA_URL')}#{data.filename}",
          kobo_payload: data,
          sample_id: sample_id
        )

        photo.save
      end
    end
    # rubocop:enable Metrics/MethodLength

    def self.sample_ids
      Sample.pluck(:kobo_id)
    end

    def project(kobo_id)
      Project.find_by(kobo_id: kobo_id)
    end
  end
end
