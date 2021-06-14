# frozen_string_literal: true

namespace :website_stats do
  task update_taxa_counts: :environment do
    include UpdateViewsAndCache

    refresh_caledna_website_stats
    refresh_pour_website_stats
  end

  task update_samples_map: :environment do
    include UpdateViewsAndCache

    refresh_samples_views
  end
end
