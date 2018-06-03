# frozen_string_literal: true

# rubocop:disable Metrics/ModuleLength
module SeedData
  def delete_records
    puts 'deleting some records...'

    Highlight.destroy_all
    Asv.destroy_all
    Photo.destroy_all
    Extraction.destroy_all
    ExtractionType.destroy_all
    Sample.destroy_all
    FieldDataProject.destroy_all
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

  # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
  def seed_samples(project)
    puts 'seeding samples...'

    FactoryBot.create_list(
      :sample, 15,
      field_data_project: project,
      status: :submitted,
      submission_date: Time.zone.now - 2.months
    )

    FactoryBot.create_list(
      :sample, 5,
      field_data_project: project,
      status: :processing_sample,
      submission_date: Time.zone.now - 2.months
    )

    FactoryBot.create_list(
      :sample, 50,
      field_data_project: project,
      status: :results_completed,
      submission_date: Time.zone.now - 2.months
    )

    Sample.all.each_with_index do |sample, i|
      sample.update(
        barcode: "K055#{i}-LC-S2",
        latitude: "37.#{i * i}6783",
        longitude: "-120.#{i * 2}23574"
      )
    end
  end

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
    else
      director = Researcher.find_by(role_cd: 'director')
      processors = Researcher.where(role_cd: 'sample_processor')
      processor1 = processors.first
      processor2 = processors.second
    end

    {
      director: director,
      processor1: processor1,
      processor2: processor2
    }
  end

  def seed_extraction_types
    puts 'seeding extraction types...'

    FactoryBot.create(
      :extraction_type,
      name: 'default'
    )
  end

  def seed_extractions(processor1, processor2, director)
    puts 'seeding extractions...'

    type_a = FactoryBot.create(:extraction_type, name: 'extraction A')
    type_b = FactoryBot.create(:extraction_type, name: 'extraction B')

    Sample.processing_sample.each do |sample|
      processor = [processor1, processor2].sample
      FactoryBot.create(
        :extraction,
        :processing_sample,
        sample: sample,
        processor_id: processor.id,
        extraction_type: type_a,
        sra_adder_id: director.id,
        local_fastq_storage_adder_id: director.id,
        status_cd: :processing_sample
      )
    end

    Sample.results_completed.each do |sample|
      processor = [processor1, processor2].sample
      FactoryBot.create(
        :extraction,
        :results_completed,
        sample: sample,
        processor_id: processor.id,
        extraction_type: type_a,
        sra_adder_id: director.id,
        local_fastq_storage_adder_id: director.id,
        status_cd: :results_completed
      )
    end

    Sample.results_completed.take(5).each do |sample|
      processor = [processor1, processor2].sample
      FactoryBot.create(
        :extraction,
        :results_completed,
        sample: sample,
        processor_id: processor.id,
        extraction_type: type_b,
        sra_adder_id: director.id,
        local_fastq_storage_adder_id: director.id,
        status_cd: :results_completed
      )
    end
  end

  def seed_asvs
    puts 'seeding asv...'

    vernacular_count = 10_000
    taxon_count = 60_000
    ids = []

    rand(1..3).times do
      taxon = Vernacular.offset(rand(vernacular_count)).take.taxon
      ids.push(taxon.taxonID)
    end

    Extraction.all.each do |extraction|
      rand(2..5).times do
        taxon = Taxon.valid.offset(rand(taxon_count)).take
        Asv.create(extraction: extraction, taxonID: taxon.taxonID)
      end
      Asv.create(extraction: extraction, taxonID: ids.sample)
    end
  end
  # rubocop:enable Metrics/AbcSize, Metrics/MethodLength

  def seed_highlights
    puts 'seeding highlights...'
    Asv.limit(4).each do |asv|
      Highlight.create(highlightable: asv, notes: Faker::Lorem.sentence)
    end
  end
end
# rubocop:enable Metrics/ModuleLength
