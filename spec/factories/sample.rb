# frozen_string_literal: true

FactoryBot.define do
  factory :sample do
    field_project

    trait :geo do
      sequence(:barcode) { |n| "k_#{n}" }
      latitude 1
      longitude 1
    end

    trait :approved do
      sequence(:barcode) { |n| "k_#{n}" }
      latitude 1
      longitude 1
      status_cd 'approved'
    end

    trait :results_completed do
      sequence(:barcode) { |n| "k_#{n}" }
      latitude 1
      longitude 1
      status_cd 'results_completed'
    end
  end
end
