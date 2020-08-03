# frozen_string_literal: true

namespace :website_stats do
  task update_taxa_counts: :environment do
    include WebsiteStats

    families_count = fetch_families_count
    species_count = fetch_species_count
    taxa_count = fetch_taxa_count

    Website::DEFAULT_SITE.update(families_count: families_count,
                                 species_count: species_count,
                                 taxa_count: taxa_count)
  end
end
