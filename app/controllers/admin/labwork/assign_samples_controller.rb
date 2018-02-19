# frozen_string_literal: true

module Admin
  module Labwork
    class AssignSamplesController < Admin::ApplicationController
      def index
        @samples = Sample.where(status_cd: :approved).page params[:page]
        @processors = Researcher.sample_processors
                                .collect { |p| [p.username, p.id] }
      end
    end
  end
end
