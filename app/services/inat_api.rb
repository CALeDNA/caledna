# frozen_string_literal: true

class InatApi
  include HTTParty
  require 'uri'

  base_uri 'api.inaturalist.org/v1'

  def taxa(keyword, rank)
    query = {
      only_id: false,
      per_page: 2,
      rank: rank
    }
    self.class.get("/taxa?q=#{keyword}", query: query)
  end
end
