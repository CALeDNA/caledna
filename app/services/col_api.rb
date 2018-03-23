# frozen_string_literal: true

class ColApi
  include HTTParty
  require 'uri'

  base_uri 'webservice.catalogueoflife.org/col/webservice'

  def taxa(keyword)
    self.class.get('/', query: { name: keyword, format: 'json'})
  end
end
