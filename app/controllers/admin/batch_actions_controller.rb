# frozen_string_literal: true

module Admin
  class BatchActionsController < Admin::ApplicationController
    def approve_samples
      if samples.update(status_cd: :approved)
        flash[:success] = 'Samples approved'
        success_handler
      else
        error_handler(object)
      end
    end

    def reject_samples
      if samples.update(status_cd: :rejected)
        flash[:success] = 'Samples rejected'
        success_handler
      else
        error_handler(object)
      end
    end

    private

    def samples
      @samples ||= Sample.where(id: batch_params[:ids])
    end

    def batch_params
      params.require(:batch_action).permit(ids: [])
    end

    def success_handler
      render json: {},
             status: :ok
    end

    def error_handler(object)
      render json: { errors: serialize(object) },
             status: :unprocessable_entity
    end

    def serialize(object)
      object.errors.messages.map do |field, errors|
        errors.map do |error_message|
          {
            status: 422,
            source: { pointer: "/data/attributes/#{field}" },
            detail: error_message
          }
        end
      end.flatten
    end
  end
end
