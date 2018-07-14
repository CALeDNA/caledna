# frozen_string_literal: true

module Admin
  class SurveysController < Admin::ApplicationController
    require_relative './services/admin_full_form'
    include AdminFullForm

    layout :resolve_layout
  end
end
