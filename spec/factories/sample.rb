# frozen_string_literal: true

FactoryBot.define do
  factory :sample do
    field_project

    trait :valid do
      sequence(:barcode) { |n| "k_#{n}" }
      latitude 1
      longitude 1
      status_cd 'approved'
    end
  end
end
