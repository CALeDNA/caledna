# frozen_string_literal: true

class SurveyResponse < ApplicationRecord
  belongs_to :survey
  has_many :survey_answers, dependent: :destroy

  accepts_nested_attributes_for :survey_answers
end
