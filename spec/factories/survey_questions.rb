# frozen_string_literal: true

FactoryBot.define do
  factory :survey_question do
    content 'question'
    type 'multiple_choice'
  end
end
