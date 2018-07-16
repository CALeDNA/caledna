# frozen_string_literal: true

class Survey < ApplicationRecord
  has_many :survey_questions, dependent: :destroy
  accepts_nested_attributes_for :survey_questions

  def passed_this_survey?(user)
    return false unless user

    previous_passing_survey(user).present?
  end

  def previous_passing_survey(user)
    return unless user

    SurveyResponse.where(user_id: user.id, survey_id: id, passed: true).last
  end
end
