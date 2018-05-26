# frozen_string_literal: true

class InaturalistApi
  include HTTParty
  base_uri 'api.inaturalist.org/v1'

  def taxa_search(keyword)
    self.class.get('/taxa', query: { q: keyword })
  end

  def fetch_taxa(id)
    self.class.get("/taxa/#{id}")
  end
end
