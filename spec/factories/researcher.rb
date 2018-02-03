# frozen_string_literal: true

FactoryBot.define do
  factory :researcher do
    sequence(:email) { |n| "user_#{n}@example.com" }
    password 'password'

    factory :director do
      role :director
    end

    factory :sample_processor do
      role :sample_processor
    end

    factory :lab_manager do
      role :lab_manager
    end
  end
end
