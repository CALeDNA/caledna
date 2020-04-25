# frozen_string_literal: true

module Api
  module V1
    class PrimersController < Api::V1::ApplicationController
      before_action :add_cors_headers

      def index
        primers = Primer.all.order(:name)
        render json: PrimerSerializer.new(primers).serializable_hash
      end
    end
  end
end
