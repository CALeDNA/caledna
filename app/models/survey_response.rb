# frozen_string_literal: true

class SurveyResponse < ApplicationRecord
  belongs_to :survey
  has_many :survey_answers, dependent: :destroy
  belongs_to :user

  accepts_nested_attributes_for :survey_answers

  def passing_score?
    total_score >= survey.passing_score
  end
end
