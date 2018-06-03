# frozen_string_literal: true

module Admin
  module Labwork
    class ApproveSamplesController < Admin::ApplicationController
      def index
        authorize 'Labwork::ApproveSamples'.to_sym, :index?

        @samples = Sample.where(status_cd: :submitted)
                         .order(:field_data_project_id, :barcode)
                         .page params[:page]
      end

      def edit_multiple_approvals
        @samples = Sample.find(params[:batch_ids])
      end

      def update_multiple_approvals
        @samples = Sample.find(params[:batch_ids])
        @samples.reject! do |sample|
          sample.update_attributes(update_params)
        end

        if @samples.empty?
          flash[:success] = 'Samples updated'
          redirect_to admin_labwork_approve_samples_path
        else
          render 'edit_multiple_approvals'
        end
      end

      private

      def update_params
        allowed_params.reject { |_, v| v.blank? }
      end

      def allowed_params
        params.require(:sample).permit(
          :status_cd,
          :director_notes
        )
      end
    end
  end
end
