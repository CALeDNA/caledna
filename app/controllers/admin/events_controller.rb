# frozen_string_literal: true

module Admin
  class EventsController < Admin::ApplicationController
    require_relative './services/admin_text_editor'
    include AdminTextEditor

    layout :resolve_layout
  end
end
