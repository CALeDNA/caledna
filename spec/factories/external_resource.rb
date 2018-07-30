# frozen_string_literal: true

FactoryBot.define do
  factory :external_resource do
    id { Faker::Number.number(5) }
    ncbi_id { Faker::Number.number(5) }
  end
end
