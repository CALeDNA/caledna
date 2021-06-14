# frozen_string_literal: true

module Admin
  module Labwork
    class HomeController < Admin::ApplicationController
      def index
        @page = Page.find_by(slug: 'admin-process-samples') || Page.new
      end
    end
  end
end
