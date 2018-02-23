# frozen_string_literal: true

class DBSeeds
  require_relative('./seed_data')
  include SeedData

  # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
  def seed
    if !Rails.env.production? && !import_taxa?
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

    import_taxonomy_data if Taxon.count.zero? && import_taxa?
  end
  # rubocop:enable Metrics/AbcSize, Metrics/MethodLength

  def import_taxa?
    ENV.fetch('IMPORT_TAXA') == 'true'
  end
end

DBSeeds.new.seed
