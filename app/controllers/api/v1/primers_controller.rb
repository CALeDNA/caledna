# frozen_string_literal: true

module Api
  module V1
    class PrimersController < Api::V1::ApplicationController
      before_action :add_cors_headers

      def index
        render json: PrimerSerializer.new(primers).serializable_hash
      end

      def primers
        @primers ||= begin
          Rails.cache.fetch(Primer::ALL_PRIMERS_CACHE_KEY) do
            Primer.order(:name).load
          end
        end
      end
    end
  end
end
