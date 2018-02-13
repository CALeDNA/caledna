# frozen_string_literal: true

def delete_records
  puts 'deleting some records...'

  Asv.destroy_all
  Photo.destroy_all
  ExtractionType.destroy_all
  Extraction.destroy_all
  Sample.destroy_all
  Researcher.destroy_all
  FieldDataProject.destroy_all
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

def seed_samples(project)
  samples = FactoryBot.create_list(
    :sample, 15,
    field_data_project: project,
    status: :submitted,
    submission_date: Time.zone.now - 2.months
  )

  samples = FactoryBot.create_list(
    :sample, 4,
    field_data_project: project,
    status: :analyzed,
    submission_date: Time.zone.now - 2.months,
  )

  FactoryBot.create_list(
    :sample, 50,
    field_data_project: project,
    status: :results_completed,
    submission_date: Time.zone.now - 2.months,
  )

  Sample.all.each_with_index do |sample, i|
    sample.update(
      barcode: "K055#{i}-LC-S2",
      latitude: "37.#{i * i}6783",
      longitude: "-120.#{i * 2}23574"
    )
  end
end

# rubocop:enable Metrics/AbcSize

unless Rails.env.production?
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

  puts 'seeding projects...'
  project = FactoryBot.create(
    :field_data_project,
    kobo_id: nil,
    name: 'Demo project',
    description: Faker::Lorem.paragraph
  )

  seed_samples(project)

  puts 'seeding extractions...'

  typeA = FactoryBot.create(:extraction_type, name: 'extraction A')
  typeB = FactoryBot.create(:extraction_type, name: 'extraction B')

  Sample.analyzed.each do |sample|
    processor = [processor1, processor2].sample
    FactoryBot.create(
      :extraction,
      :being_analyzed,
      sample: sample,
      processor_id: processor.id,
      extraction_type: typeA,
      sra_adder_id: director.id,
      local_fastq_storage_adder_id: director.id
    )
  end

  Sample.results_completed.each do |sample|
    processor = [processor1, processor2].sample
    FactoryBot.create(
      :extraction,
      :results_completed,
      sample: sample,
      processor_id: processor.id,
      extraction_type: typeA,
      sra_adder_id: director.id,
      local_fastq_storage_adder_id: director.id
    )
  end

  Sample.results_completed.take(5).each do |sample|
    processor = [processor1, processor2].sample
    FactoryBot.create(
      :extraction,
      :results_completed,
      sample: sample,
      processor_id: processor.id,
      extraction_type: typeB,
      sra_adder_id: director.id,
      local_fastq_storage_adder_id: director.id
    )
  end

  puts 'import taxonomy...'

  unless Hierarchy.count.zero?
    taxon_count = TaxonomicUnit.valid.count
    tsn = []
    rand(1..3).times do
      unit = TaxonomicUnit.valid.offset(rand(taxon_count)).take
      tsn.push(unit.tsn)
    end

    Extraction.all.each do |extraction|
      rand(1..5).times do
        unit = TaxonomicUnit.valid.offset(rand(taxon_count)).take
        Asv.create(extraction: extraction, taxonomic_unit: unit)
      end
      Asv.create(extraction: extraction, tsn: tsn.sample)
    end
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
