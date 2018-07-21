# frozen_string_literal: true

module SurveysCalculateScore
  def calculate_total_score(response)
    SurveyAnswer.where(survey_response_id: response.id)
                .sum(:score)
  end

  def clean_answer(raw_answer)
    if raw_answer.is_a? Array
      raw_answer.select(&:present?).map(&:to_i).sort
    else
      return if raw_answer.blank?
      [raw_answer.to_i]
    end
  end

  def calculate_score(question, user_answer)
    correct_answers =
      SurveyOption.where(survey_question: question, accepted_answer: true)
                  .pluck(:id)
                  .sort

    correct_answers == user_answer ? 1 : 0
  end

  def passed?(survey, total_score)
    total_score >= survey.passing_score
  end
end
