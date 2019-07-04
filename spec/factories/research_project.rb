# frozen_string_literal: true

FactoryBot.define do
  factory :research_project do
    name 'name'
    slug { "#{Faker::Team.creature}#{Faker::Number.number(5)}" }
  end
end
