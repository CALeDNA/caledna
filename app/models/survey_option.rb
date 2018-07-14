# frozen_string_literal: true

class SurveyOption < ApplicationRecord
  belongs_to :survey_question
end
