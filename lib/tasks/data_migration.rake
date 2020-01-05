# frozen_string_literal: true

namespace :data_migration do
  task add_sample_id_to_samples: :environment do
    ResearchProjectSource.find_each do |source|
      source.update(sample_id: source.sourceable_id)
    end
  end
end
