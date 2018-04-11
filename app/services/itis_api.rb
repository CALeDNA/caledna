# frozen_string_literal: true

class EolApi
  include HTTParty
  require 'uri'
  base_uri 'itis.gov/ITISWebService/services/ITISService'

  def taxa(taxa)
    self.class.get('/searchForAnyMatch', srchKey: taxa)
  end
end
