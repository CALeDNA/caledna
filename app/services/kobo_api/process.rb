# frozen_string_literal: true

module KoboApi
  class Process
    def self.import_projects(hash_payload)
      results = hash_payload.map do |project_data|
        next if imported_project_ids.include?(project_data['id'])
        save_project(project_data)
      end
      results.all? { |r| r }
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

    def self.imported_project_ids
      Project.select(:kobo_id).map(&:kobo_id)
    end
  end
end
