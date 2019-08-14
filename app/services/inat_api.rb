# frozen_string_literal: true

class InatApi
  include HTTParty
  require 'uri'

  base_uri 'api.inaturalist.org/v1'

  def taxa(keyword, rank)
    query = {
      only_id: false,
      per_page: 3,
      rank: rank
    }
    self.class.get("/taxa?q=#{keyword}", query: query)
  end

  def get_taxa(name:, rank: nil)
    response = taxa(name, rank)
    if response.success?
      yield JSON.parse(response.body)['results']
    else
      puts "API error for #{name}"
    end
  end
end
