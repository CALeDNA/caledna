# frozen_string_literal: true

class SurveyResponsesController < ApplicationController
  include SurveysCalculateScore

  def show
    flash.delete(:failure)
    @response = SurveyResponse.find(params[:id])
  end

  # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
  def create
    if user_answers_valid?
      if new_response.save
        ActiveRecord::Base.transaction do
          build_answers.each(&:save)
          total_score = calculate_total_score(new_response)
          new_response.update(
            total_score: total_score,
            passed: passed?(survey, total_score)
          )
        end

        redirect_to survey_survey_response_path(
          survey_id: survey.slug, id: new_response.id
        )
      else
        flash[:failure] = event.errors.messages.values.join('<br>')
        @survey = Survey.find(params[:survey_id])

        render 'new'
      end
    else
      flash[:failure] = 'Every question must be answered'
      @checked_options = checked_options.compact
      @survey = Survey.find(params[:survey_id])

      render 'new'
    end
  end
  # rubocop:enable Metrics/AbcSize, Metrics/MethodLength

  private

  def checked_options
    answers = []
    create_params[:survey_questions].each do |_, v|
      answers << clean_answer(v[:survey_options])
    end
    answers.flatten
  end

  def user_answers_valid?
    create_params[:survey_questions].values.all? do |q|
      clean_answer(q[:survey_options]).present?
    end
  end

  # rubocop:disable Metrics/MethodLength
  def build_answers
    answers = []
    create_params[:survey_questions].each do |question_id, v|
      user_answer = clean_answer(v[:survey_options])

      answers << SurveyAnswer.new(
        survey_question_id: question_id,
        survey_response_id: new_response.id,
        content: user_answer,
        score: calculate_score(question_id, user_answer)
      )
    end
    answers
  end
  # rubocop:enable Metrics/MethodLength

  def survey_id
    params[:survey_id]
  end

  def new_response
    @new_response ||=
      SurveyResponse.new(user_id: current_user.id, survey_id: survey_id)
  end

  def survey
    @survey ||= Survey.find(survey_id)
  end

  def create_params
    params.require(:survey).permit(
      survey_questions: [
        :survey_options,
        survey_options: []
      ]
    )
  end
end
