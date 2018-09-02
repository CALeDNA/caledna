# frozen_string_literal: true

class GlobiApi
  include HTTParty
  require 'uri'

  base_uri 'api.globalbioticinteractions.org'

  def initialize
    @options = {}
  end

  def interaction(query)
    self.class.get("/interaction?type=json.v2&#{query}", @options)
  end
end
