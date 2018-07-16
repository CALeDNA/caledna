# frozen_string_literal: true

class SurveyResponsesController < ApplicationController
  def show
    @response = SurveyResponse.find(params[:id])
  end

  def create
    if new_response.save
      if user_answers_valid?
        # TODO: add transactions
        total_score = calculate_total_score

        ActiveRecord::Base.transaction do
          build_answers.each(&:save)

          new_response.update(total_score: total_score, passed: passed?)
        end

        # TODO: don't nest response under a surveys/id/survey_responses
        redirect_to survey_survey_response_path(
          survey_id: survey.slug, id: new_response.id
        )
      else
        flash[:notice] = 'Every question must be answered'
        error_handler
      end
    else
      flash[:notice] = 'Problem saving response. Please resubmit.'
      error_handler
    end
  end

  private

  def passed?(total_score)
    total_score >= survey.passing_score
  end

  def error_handler
    # TODO: rerender invalid form will filled out answers
    redirect_to survey_path(id: survey.slug)
  end

  def calculate_total_score
    SurveyAnswer.where(survey_response_id: new_response.id)
                .sum(:score)
  end

  def user_answers_valid?
    create_params[:survey_questions].values.all? do |q|
      clean_answer(q[:survey_options]).present?
    end
  end

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

  def clean_answer(raw_answer)
    if raw_answer.is_a? Array
      raw_answer.select(&:present?).map(&:to_i).sort
    else
      [raw_answer.to_i]
    end
  end

  def calculate_score(question_id, user_answer)
    correct_answers(question_id) == user_answer ? 1 : 0
  end

  # TODO: grab all correct answers for a survey, and store in memory
  def correct_answers(question_id)
    @correct_answers =
      SurveyOption.where(survey_question_id: question_id, accepted_answer: true)
                  .pluck(:id)
                  .sort
  end

  def survey_id
    params[:survey_id]
  end

  def new_response
    @new_response ||=
      SurveyResponse.new(user_id: current_user.id, survey_id: survey_id)
  end

  # TODO: don't nest response under a surveys/id/survey_responses
  def survey
    @survey ||= Survey.find(survey_id)
  end

  private


  def create_params
    params.require(:survey).permit(
      survey_questions: [
        :survey_options,
        survey_options: []
      ]
    )
  end
end
