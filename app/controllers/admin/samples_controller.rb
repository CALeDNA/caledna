# frozen_string_literal: true

module Admin
  class SamplesController < Admin::ApplicationController
    private

    def resource_params
      clean_array_params
      super
    end

    def clean_array_params
      # NOTE: selectize multi adds '' to the array of values.
      SampleDashboard::ARRAY_FIELDS.each do |f|
        params[:sample][f] = params[:sample][f].reject(&:blank?)
      end
    end
  end
end

