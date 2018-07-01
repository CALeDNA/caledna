# frozen_string_literal: true

class DBSeeds
  require_relative('./seed_data')
  include SeedData

  def seed_basic
    delete_records
    seed_people
    seed_projects
    seed_extraction_types
    puts 'done seeding'
  end
end

db_seeds = DBSeeds.new
db_seeds.seed_basic
