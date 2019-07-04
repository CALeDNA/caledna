# frozen_string_literal: true

FactoryBot.define do
  factory :page do
    title 'MyString'
    body 'MyText'
    published false
    slug { "#{Faker::Team.creature}#{Faker::Number.number(5)}" }
  end
end
