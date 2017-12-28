# frozen_string_literal: true

module KoboApi
  class Connect
    include HTTParty
    base_uri 'kc.kobotoolbox.org/api/v1'

    def self.projects
      get('/data', headers: headers)
    end

    private_class_method

    def self.headers
      {
        'Authorization': "Token #{ENV.fetch('KOBO_TOKEN')}"
      }
    end
  end
end
