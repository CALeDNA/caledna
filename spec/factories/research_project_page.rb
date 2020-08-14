# frozen_string_literal: true

FactoryBot.define do
  factory :research_project_page do
    title 'MyString'
    body 'MyText'
    published false
    slug { "#{Faker::Team.creature}#{Faker::Number.number(5)}" }
    menu_text 'menu'
  end
end
