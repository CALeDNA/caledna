# frozen_string_literal: true

module SeedData
  def delete_records
    puts 'deleting some records...'
    sql = 'TRUNCATE researchers, extraction_types, field_data_projects CASCADE'
    ActiveRecord::Base.connection.execute(sql)
  end

  def reset_search
    puts 'reset search...'
    PgSearch::Document.delete_all(searchable_type: 'Sample')
    PgSearch::Multisearch.rebuild(Sample)
  end

  def seed_projects
    puts 'seeding projects...'

    FactoryBot.create(
      :field_data_project,
      kobo_id: nil,
      name: 'unknown',
      description: nil
    )
  end

  # rubocop:disable Metrics/MethodLength
  def seed_people
    puts 'seeding people...'
    if Researcher.count.zero?
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

      researcher1 = FactoryBot.create(
        :researcher,
        email: 'researcher@example.com',
        password: 'password',
        username: 'Researcher Jane'
      )

      researcher2 = FactoryBot.create(
        :researcher,
        email: 'researcher2@example.com',
        password: 'password',
        username: 'Researcher Bob'
      )
    else
      director = Researcher.find_by(role_cd: 'director')
      processors = Researcher.where(role_cd: 'researcher')
      researcher1 = processors.first
      researcher2 = processors.second
    end

    {
      director: director,
      researcher1: researcher1,
      researcher2: researcher2
    }
  end
  # rubocop:enable Metrics/MethodLength

  def seed_extraction_types
    puts 'seeding extraction types...'

    FactoryBot.create(
      :extraction_type,
      name: 'default'
    )
  end
end
