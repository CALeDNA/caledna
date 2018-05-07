# frozen_string_literal: true

FactoryBot.define do
  factory :ncbi_citation do
    sequence(:id) { |n| n }
  end
end
