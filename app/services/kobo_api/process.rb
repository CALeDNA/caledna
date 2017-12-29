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
        kobo_payload: hash_payload
      )

      project.save
    end

    def self.project_ids
      Project.select(:kobo_id).map(&:kobo_id)
    end

    def self.import_samples(project_id, hash_payload)
      results = hash_payload.map do |sample_data|
        next if sample_ids.include?(sample_data['_id'])
        save_sample(project_id, sample_data)
      end
      results.compact.all? { |r| r }
    end

    # rubocop:disable Metrics/MethodLength
    def self.save_sample(project_id, hash_payload)
      data = OpenStruct.new(hash_payload)
      submission_date =
        data.Enter_the_sampling_date_and_time || data._submission_time
      sample = ::Sample.new(
        project_id: project_id,
        kobo_id: data._id,
        latitude: data._geolocation.first,
        longitude: data._geolocation.second,
        submission_date: submission_date,
        letter_code: data.Which_location_lette_codes_LA_LB_or_LC,
        bar_code: data.You_re_at_your_first_r_barcodes_S1_or_S2,
        kit_number: data.What_is_your_kit_number_e_g_K0021,
        kobo_data: hash_payload
      )

      sample.save
    end
    # rubocop:enable Metrics/MethodLength

    def self.sample_ids
      Sample.select(:kobo_id).map(&:kobo_id)
    end

    def project(kobo_id)
      Project.find_by(kobo_id: kobo_id)
    end
  end
end
