# frozen_string_literal: true

FactoryBot.define do
  factory :taxon do
    taxa_dataset
    taxonID { Faker::Number.number(5) }
  end
end
