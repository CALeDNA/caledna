# frozen_string_literal: true

module Api
  module V1
    class ApplicationController < ActionController::API
      include ActionController::MimeResponds

      private

      # code from https://stackoverflow.com/a/18192803
      def add_cors_headers
        headers['Access-Control-Allow-Origin'] = allowed_origin
        headers['Access-Control-Allow-Methods'] = 'GET'
        allow_headers = request.headers['Access-Control-Request-Headers']
        if allow_headers.nil?
          allow_headers = 'Origin, Authorization, Accept, Content-Type'
        end
        headers['Access-Control-Allow-Headers'] = allow_headers
        headers['Access-Control-Allow-Credentials'] = 'true'
      end

      def allowed_origin
        origin = request.headers['Origin']

        return if origin.blank?
        return origin if origin.starts_with?('http://localhost:')
        return origin if origin.ends_with?(ENV.fetch('ALLOWED_ORIGIN'))
      end
    end
  end
end
