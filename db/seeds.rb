# frozen_string_literal: true

def delete_records
  puts 'deleting some records...'
  Researcher.delete_all
  Role.delete_all

  sql = 'DELETE from researchers_roles'
  ActiveRecord::Base.connection.execute(sql)

  project = Project.find_by(name: 'Demo project')
  return if project.blank?
  Sample.where(project: project).delete_all
  project.delete
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
  user1 = FactoryBot.create(
    :researcher,
    email: 'director@example.com',
    password: 'password',
    username: 'Director Jane'
  )
  user1.add_role :director

  user2 = FactoryBot.create(
    :researcher,
    email: 'lab_manager@example.com',
    password: 'password',
    username: 'Lab Manager Jane'
  )
  user2.add_role :lab_manager

  user3 = FactoryBot.create(
    :researcher,
    email: 'sample_processor@example.com',
    password: 'password',
    username: 'Sample Processor Jane'
  )
  user3.add_role :sample_processor


  puts 'seeding projects...'
  project = FactoryBot.create(
    :project,
    kobo_id: nil,
    name: 'Demo project',
    description: Faker::Lorem.sentence
  )

  puts 'seeding samples...'
  FactoryBot.create_list(
    :sample, 2,
    project: project,
    status: :submitted,
    submission_date: Time.zone.now - 2.months
  )
  FactoryBot.create_list(
    :sample, 2,
    project: project,
    status: :analyzed,
    submission_date: Time.zone.now - 2.months,
    analysis_date: Time.zone.now - 1.months
  )

  FactoryBot.create_list(
    :sample, 2,
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
