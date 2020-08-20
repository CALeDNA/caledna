# frozen_string_literal: true

module Admin
  class PlacesController < Admin::ApplicationController
    def resource_params
      input = params[resource_class.model_name.param_key]
      params.require(resource_class.model_name.param_key).
        permit(dashboard.permitted_attributes).
        merge(geom: "POINT(#{input[:longitude]} #{input[:latitude]})").
        transform_values { |value| value == "" ? nil : value }
    end
  end
end
