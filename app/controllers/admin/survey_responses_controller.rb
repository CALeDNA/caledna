# frozen_string_literal: true

module Admin
  class SurveyResponsesController < Admin::ApplicationController
    include SurveysCalculateScore

    def show
      response = requested_resource
      @user_answers = user_answers(response)
      @correct_answers = correct_answers(response)
      @survey = response.survey
      super
    end
  end
end
