# frozen_string_literal: true

def delete_records
  puts 'deleting some records...'

  Specimen.destroy_all
  Photo.destroy_all
  Sample.destroy_all
  Researcher.destroy_all
  Project.destroy_all
end

def reset_search
  puts 'reset search...'
  PgSearch::Document.delete_all(searchable_type: 'Sample')
  PgSearch::Multisearch.rebuild(Sample)
end

# rubocop:disable Metrics/AbcSize
def import_taxonomy_data
  puts 'seeding taxonomy...'
  sql_file = Rails.root.join('db').join('data').join('itis_condensed_data.sql')
  host = ActiveRecord::Base.connection_config[:host]
  user = ActiveRecord::Base.connection_config[:username]
  db = ActiveRecord::Base.connection_config[:database]

  cmd = 'psql '
  cmd += "--host #{host} " if host.present?
  cmd += "--username #{user} " if user.present?
  cmd += "#{db} < #{sql_file}"
  exec cmd
end
# rubocop:enable Metrics/AbcSize

unless Rails.env.production?
  delete_records
  reset_search

  puts 'seeding people...'
  FactoryBot.create(
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

  FactoryBot.create(
    :sample_processor,
    email: 'sample_processor@example.com',
    password: 'password',
    username: 'Sample Processor Jane'
  )

  processor = FactoryBot.create(
    :sample_processor,
    email: 'sample_processor2@example.com',
    password: 'password',
    username: 'Sample Processor Bob'
  )

  puts 'seeding projects...'
  project = FactoryBot.create(
    :project,
    kobo_id: nil,
    name: 'Demo project',
    description: Faker::Lorem.sentence
  )

  puts 'seeding samples...'
  samples = FactoryBot.create_list(
    :sample, 15,
    project: project,
    status: :submitted,
    submission_date: Time.zone.now - 2.months
  )
  samples.first.update(processor: processor)
  samples.second.update(processor: processor)

  samples = FactoryBot.create_list(
    :sample, 4,
    project: project,
    status: :analyzed,
    submission_date: Time.zone.now - 2.months,
    analysis_date: Time.zone.now - 1.months
  )
  samples.first.update(processor: processor)

  FactoryBot.create_list(
    :sample, 50,
    project: project,
    status: :results_completed,
    submission_date: Time.zone.now - 2.months,
    analysis_date: Time.zone.now - 1.months,
    results_completion_date: Time.zone.now - 1.week
  )

  Sample.all.each_with_index do |sample, i|
    sample.update(
      bar_code: "K055#{i}-LC-S2",
      latitude: "37.#{i * i}6783",
      longitude: "-120.#{i * 2}23574"
    )
  end

  taxon_count = TaxonomicUnit.valid.count
  tsn = []
  rand(1..3).times do |i|
    unit = TaxonomicUnit.valid.offset(rand(taxon_count)).take
    tsn.push(unit.tsn)
  end

  Sample.results_completed.each do |sample|
    rand(1..5).times do |i|
      unit = TaxonomicUnit.valid.offset(rand(taxon_count)).take
      Specimen.create(sample: sample, taxonomic_unit: unit)
    end
    Specimen.create(sample: sample, tsn: tsn.sample)
  end

  puts 'done seeding'
end

import_taxonomy_data if Hierarchy.count.zero?

Kingdom.all.pluck(:kingdom_name).each do |name|
  sql = 'UPDATE taxonomic_units SET highlight = true ' \
  "WHERE complete_name = '#{name.strip}' " \
  'AND tsn NOT IN (590735, 43780, 202421)'
  ActiveRecord::Base.connection.execute(sql)
end
