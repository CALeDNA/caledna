# frozen_string_literal: true

class DBSeeds
  require_relative('./seed_data')
  include SeedData
  require_relative '../app/services/custom_counter'
  include CustomCounter

  def seed_basic
    delete_records
    seed_people
    seed_website
    seed_primers
    seed_projects
    update_asvs_count
    update_asvs_count_la_river
    update_views
    Rails.cache.clear
  end
end

db_seeds = DBSeeds.new
db_seeds.seed_basic
