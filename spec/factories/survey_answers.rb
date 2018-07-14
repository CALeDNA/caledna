# frozen_string_literal: true

FactoryBot.define do
  factory :survey_answer do
    survey_question
    survey_response
    content 'answer'
  end
end
