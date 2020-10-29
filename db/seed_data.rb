# frozen_string_literal: true

module SeedData
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
end
