# frozen_string: literal

class InaturalistApi
  include HTTParty
  base_uri 'api.inaturalist.org/v1'

  def initialize(keyword)
    @options = { query: { q: keyword } }
  end

  def taxa
    self.class.get('/taxa', @options)
  end
end
