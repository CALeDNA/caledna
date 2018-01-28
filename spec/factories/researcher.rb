# frozen_string_literal: true

FactoryBot.define do
  factory :researcher do
    sequence(:email) { |n| "user_#{n}@example.com" }
    password 'password'

    factory :director do
      after(:create) { |user| user.add_role(:director) }
    end

    factory :sample_processor do
      after(:create) { |user| user.add_role(:sample_processor) }
    end

    factory :lab_manager do
      after(:create) { |user| user.add_role(:lab_manager) }
    end
  end
end
