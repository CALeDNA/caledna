# frozen_string_literal: true

namespace :research_project_source do
  task change_extraction_to_sample: :environment do
    ResearchProjectSource.where(sourceable_type: 'Extraction').each do |rps|
      rps.sourceable_id = rps.sample_id
      rps.sourceable_type = 'Sample'
      rps.save
    end
  end
end
