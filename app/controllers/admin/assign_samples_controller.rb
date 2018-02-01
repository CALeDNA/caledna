# frozen_string_literal: true

module Admin
  class AssignSamplesController < Admin::ApplicationController
    def index
      @samples = Sample.where(status: :approved)
    end
    def create; end
  end
end
