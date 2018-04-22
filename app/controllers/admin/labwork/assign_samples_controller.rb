# frozen_string_literal: true

module Admin
  module Labwork
    class AssignSamplesController < Admin::ApplicationController
      def index
        authorize 'Labwork::AssignSamples'.to_sym, :index?

        @samples = Sample.where(status_cd: :approved)
                         .order(:field_data_project_id, :barcode)
                         .page params[:page]
        @processors = Researcher.sample_processors
                                .collect { |p| [p.username, p.id] }
      end
    end
  end
end
