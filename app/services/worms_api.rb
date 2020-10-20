# frozen_string_literal: true

class WormsApi
  include HTTParty
  require 'uri'

  base_uri 'marinespecies.org/rest'

  def initialize
    @options = {}
  end

  def taxa_fuzzy(keyword)
    self.class.get('/AphiaRecordsByMatchNames',
                   query: { 'scientificnames[]': keyword, marine_only: true })
  end
end
