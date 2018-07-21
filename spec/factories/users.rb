# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    username { Faker::Internet.user_name }
    email { Faker::Internet.email }
    password 'password'
    agree true
  end
end
