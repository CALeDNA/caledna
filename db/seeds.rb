# frozen_string_literal: true

class DBSeeds
  require_relative('./seed_data')
  include SeedData

  def seed_basic
    seed_people
    seed_website
  end
end

db_seeds = DBSeeds.new
db_seeds.seed_basic
