# frozen_string_literal: true

FactoryBot.define do
  factory :sample do
    field_project
    sequence(:barcode) { |n| "k_#{n}" }

    trait :geo do
      latitude 1
      longitude 1
    end

    trait :approved do
      latitude 1
      longitude 1
      status_cd 'approved'
    end

    trait :results_completed do
      latitude 1
      longitude 1
      status_cd 'results_completed'
    end
  end
end
