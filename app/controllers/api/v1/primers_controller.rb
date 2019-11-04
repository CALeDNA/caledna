# frozen_string_literal: true

module Api
  module V1
    class PrimersController < Api::V1::ApplicationController
      before_action :add_cors_headers

      def index
        render json: PrimerSerializer.new(Primer.all)
      end
    end
  end
end
