# frozen_string_literal: true

FactoryBot.define do
  factory :ncbi_name do
    taxon_id { Faker::Number.number(5) }
  end
end
