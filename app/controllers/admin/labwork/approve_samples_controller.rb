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
    end
  end
end
