# frozen_string_literal: true

FactoryBot.define do
  factory :ncbi_node do
    taxon_id { Faker::Number.number(5) }
    ncbi_division
    asvs_count 2
    asvs_count_la_river 2
  end
end
