# frozen_string_literal: true

class SurveyAnswer < ApplicationRecord
  belongs_to :survey_response
end
