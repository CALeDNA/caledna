# frozen_string_literal: true

FactoryBot.define do
  factory :taxa_dataset do
    datasetID { Faker::Number.number(5) }
  end
end
