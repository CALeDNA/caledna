# frozen_string_literal: true

module Admin
  module Labwork
    class BatchActionsController < Admin::ApplicationController
      skip_before_action :verify_authenticity_token

      def approve_samples
        authorize 'Labwork::ApproveSamples'.to_sym, :create?

        results = samples.update(status_cd: :approved)

        if results.all?(&:valid?)
          flash[:success] = 'Samples approved'
        else
          errors =
            results.map { |r| r.errors.messages.values }.flatten.join('; ')
          flash[:error] = errors
        end
      end

      # rubocop:disable Metrics/MethodLength
      def change_longitude_sign
        authorize 'Labwork::ApproveSamples'.to_sym, :create?

        res = samples.map do |sample|
          next if sample.longitude.blank?
          sample.update(longitude: sample.longitude * -1)
        end

        if res.all? { |r| r }
          flash[:success] = 'Longitude changed'
          success_handler
        else
          error_handler(samples)
        end
      end
      # rubocop:enable Metrics/MethodLength

      private

      def processor_id
        return if batch_params['data'].blank?
        JSON.parse(batch_params['data'])['processor_id']
      end

      def samples
        @samples ||= Sample.where(id: batch_params[:ids])
      end

      def batch_params
        params.require(:batch_action).permit(:data, ids: [])
      end

      def success_handler
        render json: {},
               status: :ok
      end

      def error_handler(object)
        render json: { errors: serialize(object) },
               status: :unprocessable_entity
      end

      def error_handler_message(message)
        render json: { errors: message },
               status: :unprocessable_entity
      end

      def serialize(results)
        errors = results.map { |r| r.errors.messages.values }.flatten.join('; ')
        {
          status: 422,
          detail: errors
        }
      end
    end
  end
end
