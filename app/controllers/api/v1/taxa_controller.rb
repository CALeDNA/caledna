# frozen_string_literal: true

module Api
  module V1
    class TaxaController < Api::V1::ApplicationController
      def index
        taxa = ::Taxon.where('lower("canonicalName") like ?', "#{query}%")
                      .limit(10)

        options = {}
        render json: ::TaxonSerializer.new(taxa, options).serialized_json
      end

      private

      def query
        params[:query].downcase
      end
    end
  end
end
