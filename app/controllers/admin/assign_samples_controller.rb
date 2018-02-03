# frozen_string_literal: true

module Admin
  class AssignSamplesController < Admin::ApplicationController
    def index

      @samples = Sample.where(status_cd: :approved).page params[:page]
      @processors = Researcher.with_role(:sample_processor)
                              .collect { |p| [p.username, p.id] }
    end
  end
end
