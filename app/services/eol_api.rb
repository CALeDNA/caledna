# frozen_string_literal: true

class EolApi
  include HTTParty
  require 'uri'

  base_uri 'eol.org/api'

  def taxa(keyword)
    self.class.get("/search/#{URI.encode(keyword)}.json", query: { exact: 1 })
  end

  def fetch_page(taxon_id)
    query = {
      taxonomy: false,
      id: taxon_id,
      images_per_page: 1,
      texts_per_page: 0,
      sounds_per_page: 0,
      videos_per_page: 0
    }
    self.class.get('/pages/1.0.json?', query: query)
  end

  def fetch_media(media_id)
    query = {
      taxonomy: false
    }
    self.class.get("/data_objects/1.0/#{media_id}.json?", query: query)
  end
end
