# frozen_string_literal: true

def delete_records
  puts 'deleting some records...'
  researcher = Researcher.find_by(email: 'user@example.com')
  researcher.delete if researcher.present?

  project = Project.find_by(name: 'Demo project')
  return if project.blank?
  Sample.where(project: project).delete_all
  project.delete
end

def reset_search
  puts 'reset search...'
  PgSearch::Document.delete_all(searchable_type: 'Project')
  PgSearch::Document.delete_all(searchable_type: 'Sample')
  PgSearch::Multisearch.rebuild(Project, Sample)
end

unless Rails.env.production?
  delete_records
  reset_search

  puts 'seeding people...'
  FactoryBot.create(
    :researcher,
    email: 'user@example.com',
    password: 'password',
    username: 'Jane Doe'
  )

  puts 'seeding projects...'
  project = FactoryBot.create(
    :project,
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
