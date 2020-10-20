# frozen_string_literal: true

class ItisApi
  include HTTParty
  require 'uri'

  base_uri 'www.itis.gov/ITISWebService/jsonservice'

  def initialize
    @options = {}
  end

  def taxa(keyword)
    self.class.get('/searchForAnyMatch',
                   query: { srchKey: keyword })
  end
end
