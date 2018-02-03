# frozen_string_literal: true

def delete_records
  puts 'deleting some records...'

  Photo.destroy_all
  Sample.destroy_all
  Researcher.destroy_all
  Role.destroy_all
  Project.destroy_all

  sql = 'DELETE from researchers_roles'
  ActiveRecord::Base.connection.execute(sql)
end

def reset_search
  puts 'reset search...'
  PgSearch::Document.delete_all(searchable_type: 'Sample')
  PgSearch::Multisearch.rebuild(Sample)
end

puts 'seeding roles...'
Role.create(name: :director)
Role.create(name: :lab_manager)
Role.create(name: :sample_processor)

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
    :sample, 2,
    project: project,
    status: :analyzed,
    submission_date: Time.zone.now - 2.months,
    analysis_date: Time.zone.now - 1.months
  )
  samples.first.update(processor: processor)

  FactoryBot.create_list(
    :sample, 4,
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

  puts 'done seeding'
end
