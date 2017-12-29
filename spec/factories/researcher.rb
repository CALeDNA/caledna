# frozen_string_literal: true

FactoryBot.define do
  factory :researcher do
    email { Faker::Internet.email }
    password 'password'
  end
end
