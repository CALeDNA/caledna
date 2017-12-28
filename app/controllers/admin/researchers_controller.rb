# frozen_string_literal: true

module Admin
  class ResearchersController < Admin::ApplicationController
    # NOTE: Changed the generated Administrate file. Customize params so admins
    # can leave passwords blank when editing admins.
    private

    def resource_params
      raw_params.select { |_k, v| v.present? }
    end

    def raw_params
      params.require(resource_class.model_name.param_key)
            .permit(dashboard.permitted_attributes)
            .transform_values { |v| read_param_value(v) }
    end

    def read_param_value(data)
      # rubocop:disable Style/GuardClause
      if data.is_a?(ActionController::Parameters) && data[:type]
        if data[:type] == Administrate::Field::Polymorphic.to_s
          GlobalID::Locator.locate(data[:value])
        else
          raise "Unrecognised param data: #{data.inspect}"
        end
      else
        data
      end
      # rubocop:enable Style/GuardClause
    end
  end
end
