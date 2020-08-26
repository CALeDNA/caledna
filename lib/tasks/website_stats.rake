# frozen_string_literal: true

namespace :website_stats do
  task update_taxa_counts: :environment do
    include WebsiteStats

    refresh_caledna_website_stats
    refresh_pour_website_stats
  end

  task update_samples_map: :environment do
    include WebsiteStats

    refresh_samples_map
  end
end
