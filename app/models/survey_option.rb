# frozen_string_literal: true

class SurveyOption < ApplicationRecord
  belongs_to :survey_question
  has_one_attached :photo
end
