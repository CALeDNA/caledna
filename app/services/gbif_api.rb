# frozen_string_literal: true

class GbifApi
  include HTTParty
  require 'uri'

  base_uri 'api.gbif.org/v1'

  def initialize
    @options = {}
  end

  def datasets(id)
    self.class.get("/dataset/#{id}", @options)
  end

  def taxa(keyword)
    self.class.get('/species/match', query: { name: keyword })
  end

  def taxa_by_rank(query)
    self.class.get('/species/match', query: query)
  end

  def media(id)
    self.class.get("/species/#{id}/media", @options)
  end
end
