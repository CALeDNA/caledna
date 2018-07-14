# frozen_string_literal: true

class SurveyQuestion < ApplicationRecord
  belongs_to :survey
  has_many :survey_options, dependent: :destroy

  accepts_nested_attributes_for :survey_options

  as_enum :type, %i[multiple_choice check_boxes], map: :string
end
