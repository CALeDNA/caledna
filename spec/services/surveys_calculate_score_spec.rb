# frozen_string_literal: true

require 'rails_helper'

describe SurveysCalculateScore do
  let(:dummy_class) { Class.new { extend SurveysCalculateScore } }

  describe '#calculate_total_score' do
    def subject(response)
      dummy_class.calculate_total_score(response)
    end

    def create_qa(survey, response, score: 0)
      question = create(:survey_question, survey: survey)
      create(:survey_answer, score: score, survey_question: question,
                             survey_response: response)
    end

    xit 'sums all the answer scores for a given response' do
      survey = create(:survey)
      response = create(:survey_response, survey: survey)
      create_qa(survey, response, score: 1)
      create_qa(survey, response, score: 2)

      expect(subject(response)).to eq(3)
    end

    xit 'returns 0 if there are no answers for a given response' do
      response = create(:survey_response)

      expect(subject(response)).to eq(0)
    end

    xit 'ignores answers for other responses' do
      survey = create(:survey)
      response1 = create(:survey_response, survey: survey)
      create_qa(survey, response1, score: 1)
      response2 = create(:survey_response, survey: survey)
      create_qa(survey, response2, score: 1)

      expect(subject(response1)).to eq(1)
    end
  end

  # rubocop:disable Style/WordArray
  describe '#clean_answer' do
    def subject(raw_answer)
      dummy_class.clean_answer(raw_answer)
    end

    context 'when passed in an array of string numbers' do
      it 'returns an array of integers' do
        raw_answer = ['1', '2']

        expect(subject(raw_answer)).to eq([1, 2])
      end

      it 'sorts the answers' do
        raw_answer = ['2', '3', '1']

        expect(subject(raw_answer)).to eq([1, 2, 3])
      end

      it 'ignores empty strings' do
        raw_answer = ['1', '', '2']

        expect(subject(raw_answer)).to eq([1, 2])
      end
    end

    context 'when passed in a string' do
      it 'returns nil when passed in an empty string' do
        raw_answer = ''

        expect(subject(raw_answer)).to eq(nil)
      end

      it 'returns an array of integers when passed in one number string' do
        raw_answer = '1'

        expect(subject(raw_answer)).to eq([1])
      end
    end
  end
  # rubocop:enable Style/WordArray

  describe '#calculate_score' do
    def subject(question, user_answer)
      dummy_class.calculate_score(question, user_answer)
    end

    context 'when answer has one correct option' do
      it 'returns 1 if user submits correct option' do
        user_answer = [10]
        question = create(:survey_question)
        create(:survey_option, id: 10, survey_question: question,
                               accepted_answer: true)

        expect(subject(question, user_answer)).to eq(1)
      end

      it 'returns 0 if user submits incorrect option' do
        user_answer = [11]
        question = create(:survey_question)
        create(:survey_option, id: 10, survey_question: question,
                               accepted_answer: true)

        expect(subject(question, user_answer)).to eq(0)
      end
    end

    context 'when answer has multiple correct options' do
      it 'returns 1 if user submits all the correct options' do
        user_answer = [1, 2]
        question = create(:survey_question)
        create(:survey_option, id: 1, survey_question: question,
                               accepted_answer: true)
        create(:survey_option, id: 2, survey_question: question,
                               accepted_answer: true)

        expect(subject(question, user_answer)).to eq(1)
      end

      it 'returns 0 if user submits some of the correct options' do
        user_answer = [1]
        question = create(:survey_question)
        create(:survey_option, id: 1, survey_question: question,
                               accepted_answer: true)
        create(:survey_option, id: 2, survey_question: question,
                               accepted_answer: true)

        expect(subject(question, user_answer)).to eq(0)
      end

      it 'returns 0 if user submits incorrect options' do
        user_answer = [3]
        question = create(:survey_question)
        create(:survey_option, id: 1, survey_question: question,
                               accepted_answer: true)
        create(:survey_option, id: 2, survey_question: question,
                               accepted_answer: true)

        expect(subject(question, user_answer)).to eq(0)
      end
    end
  end

  describe '#passed?' do
    def subject(survey, total_score)
      dummy_class.passed?(survey, total_score)
    end

    it "returns true if score equals survey's passing score" do
      total_score = 5
      survey = create(:survey, passing_score: 5)

      expect(subject(survey, total_score)).to eq(true)
    end

    it "returns true if score is greater than survey's passing score" do
      total_score = 6
      survey = create(:survey, passing_score: 5)

      expect(subject(survey, total_score)).to eq(true)
    end

    it "returns false if score is less than survey's passing score" do
      total_score = 4
      survey = create(:survey, passing_score: 5)

      expect(subject(survey, total_score)).to eq(false)
    end
  end
end
