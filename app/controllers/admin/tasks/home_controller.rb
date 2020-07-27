# frozen_string_literal: true

module Admin
  module Tasks
    class HomeController < Admin::ApplicationController
      def index
        authorize 'Tasks::Home'.to_sym, :index?
      end
    end
  end
end
