# frozen_string_literal: true

FactoryBot.define do
  factory :researcher do
    sequence(:email) { |n| "user_#{n}@example.com" }
    password 'password'
  end
end
