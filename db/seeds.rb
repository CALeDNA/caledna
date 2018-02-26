# frozen_string_literal: true

class DBSeeds
  require_relative('./seed_data')
  require_relative('./seed_import')
  include SeedData
  include SeedImport

  # rubocop:disable Metrics/MethodLength
  def seed
    delete_records
    reset_search

    puts 'seeding people...'
    director = FactoryBot.create(
      :director,
      email: 'director@example.com',
      password: 'password',
      username: 'Director Jane'
    )

    FactoryBot.create(
      :lab_manager,
      email: 'lab_manager@example.com',
      password: 'password',
      username: 'Lab Manager Jane'
    )

    processor1 = FactoryBot.create(
      :sample_processor,
      email: 'sample_processor@example.com',
      password: 'password',
      username: 'Sample Processor Jane'
    )

    processor2 = FactoryBot.create(
      :sample_processor,
      email: 'sample_processor2@example.com',
      password: 'password',
      username: 'Sample Processor Bob'
    )

    project = seed_projects
    seed_samples(project)
    seed_extractions(processor1, processor2, director)
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
db_seeds.import_taxonomy_data if Taxon.count.zero? && import_taxa
db_seeds.import_taxa_datasets if import_taxa_datasets
db_seeds.seed if !Rails.env.production? && Taxon.count.positive? && import_main
