# frozen_string_literal: true

namespace :data_migration do
  task add_sample_id_to_extractions: :environment do
    ResearchProjectExtraction.find_each do |extraction|
      extraction.update(sample_id: extraction.extraction.sample.id)
    end
  end
end
