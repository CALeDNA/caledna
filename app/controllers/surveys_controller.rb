# frozen_string_literal: true

class SurveysController < ApplicationController
  def show
    @survey = Survey.find_by(slug: params[:id])
  end
end
