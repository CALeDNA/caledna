# frozen_string_literal: true

FactoryBot.define do
  factory :survey_option do
    content 'option'
    survey_question
  end
end
