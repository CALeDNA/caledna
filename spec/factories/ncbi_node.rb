# frozen_string_literal: true

FactoryBot.define do
  factory :ncbi_node do
    taxon_id { Faker::Number.number(5) }
    ncbi_division
  end
end
