# frozen_string_literal: true

module SeedData
  include WebsiteStats

  # rubocop:disable Metrics/MethodLength
  def seed_people
    return unless Researcher.count.zero?
    puts 'creating people...'
    FactoryBot.create(
      :director,
      email: 'director@example.com',
      password: 'password',
      username: 'Director Jane'
    )

    FactoryBot.create(
      :researcher,
      email: 'researcher@example.com',
      password: 'password',
      username: 'Researcher Jane'
    )
  end
  # rubocop:enable Metrics/MethodLength

  def seed_website
    puts 'creating websites...'
    FactoryBot.create(:website, name: 'CALeDNA')
    FactoryBot.create(:website, name: 'Protecting Our River')
  end

  def seed_primers
    puts 'creating primers...'
    FactoryBot.create(:primer, name: 'primer 1')
    FactoryBot.create(:primer, name: 'primer 2')
  end

  def approved_published_project
    field = FactoryBot.create(
      :field_project,
      name: 'field project 2',
      description: 'field project 2 description',
      kobo_id: 1,
      published: true
    )

    place = Place.where(place_source_type_cd: :UCNRS).third
    create_samples(field, place, 0.002, :approved)
    FactoryBot.create(:sample, field_project: field, status: :submitted)
    FactoryBot.create(:sample, field_project: field, status: :rejected)
  end

  def results_published_project
    field = FactoryBot.create(
      :field_project,
      name: 'field project 1',
      description: 'field project 1 description',
      kobo_id: 2,
      published: true
    )

    place = Place.where(place_source_type_cd: :UCNRS).second
    samples = create_samples(field, place, 0.002)

    research = FactoryBot.create(
      :research_project,
      name: 'research project 1',
      published: true
    )
    samples.each do |sample|
      create_edna_results(research, sample)
    end
  end

  def results_unpublished_project
    field = FactoryBot.create(
      :field_project,
      name: 'field project 3',
      description: 'field project 3 description',
      kobo_id: 3,
      published: false
    )

    place = Place.where(place_source_type_cd: :UCNRS).first
    samples = create_samples(field, place, 0.001)

    research = FactoryBot.create(
      :research_project,
      name: 'research project 3',
      published: false
    )
    samples.each do |sample|
      create_edna_results(research, sample)
    end
  end


  def create_edna_results(research_project, sample)
    50.times do
      FactoryBot.create(
        :asv, research_project: research_project, sample: sample,
              primer: Primer.first,
              taxon_id: NcbiNode.find(rand(2_000_000)).taxon_id
      )
    end

    40.times do
      FactoryBot.create(
        :asv, research_project: research_project, sample: sample,
              primer: Primer.second,
              taxon_id: NcbiNode.find(rand(2_000_000)).taxon_id
      )
    end

    animals = NcbiNode.where(cal_division_id: 12).limit(12).sample(5)
    animals.each do |taxon|
      FactoryBot.create(
        :asv, research_project: research_project, sample: sample,
              primer: Primer.second,
              taxon_id: taxon.taxon_id
      )
    end

    plants = NcbiNode.where(cal_division_id: 14).limit(12).sample(5)
    plants.each do |taxon|
      FactoryBot.create(
        :asv, research_project: research_project, sample: sample,
              primer: Primer.second,
              taxon_id: taxon.taxon_id
      )
    end

    FactoryBot.create(:research_project_source,
                      research_project: research_project, sourceable: sample)
    FactoryBot.create(:sample_primer, research_project: research_project,
                                      sample: sample, primer: Primer.first)
    FactoryBot.create(:sample_primer, research_project: research_project,
                                      sample: sample, primer: Primer.second)
  end

  def create_samples(field, place, offset, status = :results_completed)
    sample1 = FactoryBot.create(
      :sample,
      field_project: field,
      status: status,
      latitude: place.latitude + offset,
      longitude: place.longitude + offset
    )

    sample2 = FactoryBot.create(
      :sample,
      field_project: field,
      status: status,
      latitude: place.latitude + (offset * 2),
      longitude: place.longitude + (offset * 2)
    )

    sample3 = FactoryBot.create(
      :sample,
      field_project: field,
      status: status,
      latitude: place.latitude + (offset * 3),
      longitude: place.longitude + (offset * 3)
    )
    [sample1, sample2, sample3]
  end

  def river_project
    places = Place.where(place_type_cd: :pour_location).limit(2)

    field1 = FactoryBot.create(
      :field_project,
      name: 'Los Angeles River field 1',
      description: 'Los Angeles River field 1 description',
      kobo_id: 4,
      published: true
    )

    field2 = FactoryBot.create(
      :field_project,
      name: 'Los Angeles River field 2',
      description: 'Los Angeles River field 2 description',
      kobo_id: 5,
      published: true
    )

    samples1 = create_samples(field1, places[0], 0.0001)
    samples2 = create_samples(field1, places[1], 0.0002)
    samples3 = create_samples(field2, places[0], -0.0001)
    samples4 = create_samples(field2, places[1], -0.0002)
    samples5 = create_samples(field2, places[1], -0.0003)

    research1 = FactoryBot.create(
      :research_project,
      name: 'Los Angeles River research 1',
      published: true
    )

    research2 = FactoryBot.create(
      :research_project,
      name: 'Los Angeles River research 2',
      published: true
    )

    research3 = FactoryBot.create(
      :research_project,
      name: 'Los Angeles River research 3',
      published: false
    )

    (samples1 + samples2).each do |sample|
      create_edna_results(research1, sample)
    end

    (samples3 + samples4).each do |sample|
      create_edna_results(research2, sample)
    end

    samples5.each do |sample|
      create_edna_results(research3, sample)
    end
  end

  def seed_projects
    puts 'creating projects...'
    approved_published_project
    results_published_project
    results_unpublished_project
    river_project
  end

  def update_views
    puts 'updating views...'
    refresh_samples_map
    refresh_ncbi_nodes_edna
    change_websites_update_at
    refresh_caledna_website_stats
    refresh_pour_website_stats
  end

  def delete_records
    puts 'deleting some records...'
    sql = 'TRUNCATE researchers, websites, field_projects, ' \
      'research_projects, samples, asvs, research_project_sources, '\
      'sample_primers CASCADE'
    ActiveRecord::Base.connection.execute(sql)
  end
end
