# frozen_string_literal: true

FactoryBot.define do
  factory :website do
    name { Faker::Internet.user_name }
  end
end
