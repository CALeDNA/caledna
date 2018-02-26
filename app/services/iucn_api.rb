# frozen_string_literal: true

class IucnApi
  include HTTParty
  require 'uri'

  CATEGORIES = {
    EX: 'Extinct',
    EW: 'Extinct in the Wild',
    CR: 'Critically Endangered',
    EN: 'Endangered',
    VU: 'Vulnerable',
    NT: 'Near Threatened',
    LC: 'Least Concern',
    DD: 'Data Deficient',
    NE: 'Not Evaluated'
  }.freeze

  base_uri 'apiv3.iucnredlist.org/api/v3'

  def initialize
    @options = { query: { token: ENV.fetch('IUCN_TOKEN') } }
  end

  def species(keyword)
    self.class.get("/species/#{URI.encode(keyword.downcase)}", @options)
  end
end
