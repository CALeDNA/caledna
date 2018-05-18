# frozen_string_literal: true

class DBSeeds
  require_relative('./seed_data')
  require_relative('./seed_import')
  include SeedData
  include SeedImport

  def seed_basic
    delete_records
    reset_search
    seed_people
    seed_projects
    seed_extraction_types
    puts 'done seeding'
  end

  # rubocop:disable Metrics/MethodLength
  def seed_fake_data
    delete_records
    reset_search
    people = seed_people
    project = seed_projects
    seed_extraction_types
    seed_samples(project)
    seed_extractions(people[:processor1], people[:processor2],
                     people[:director])
    seed_asvs
    seed_highlights

    puts 'done seeding'
  end
  # rubocop:enable Metrics/MethodLength
end

import_main = ENV.fetch('IMPORT_MAIN', 'true') == 'true'
import_taxa = ENV.fetch('IMPORT_TAXA', 'false') == 'true'
import_taxa_datasets = ENV.fetch('IMPORT_TAXA_DATASETS', 'false') == 'true'

db_seeds = DBSeeds.new
db_seeds.seed_basic

has_taxa = Vernacular.count.positive?
db_seeds.import_taxonomy_data if import_taxa && !has_taxa
db_seeds.import_taxa_datasets if import_taxa_datasets
db_seeds.seed_fake_data if !Rails.env.production? && import_main && has_taxa
