# frozen_string_literal: true

class InatApi
  include HTTParty
  require 'uri'

  base_uri 'api.inaturalist.org/v1'

  def taxa(keyword, rank)
    query = {
      only_id: false,
      per_page: 3,
      rank: rank,
      q: keyword
    }.compact
    self.class.get('/taxa', query: query)
  end

  def taxa_all_names(keyword, rank = nil)
    query = {
      only_id: false,
      rank: rank,
      q: keyword,
      all_names: true
    }.compact
    self.class.get('/taxa', query: query)
  end

  def get_taxa(name:, rank: nil)
    response = taxa(name, rank)
    if response.success?
      yield JSON.parse(response.body)['results']
    else
      puts "API error for #{name}"
    end
  end

  def taxon_by_id(id)
    self.class.get("/taxa/#{id}")
  end

  def get_taxon(id)
    response = taxon_by_id(id)
    if response.success?
      yield JSON.parse(response.body)['results']
    else
      puts "API error for #{id}"
    end
  end

  def default_photo(taxon_id)
    response = taxon_by_id(taxon_id)
    return if response['results'].blank?
    return if response['results'].first['default_photo'].blank?

    default_photo = response['results'].first['default_photo']
    url = default_photo['medium_url']
    photo_id = default_photo['id']
    attribution = default_photo['attribution']

    { url: url, photo_id: photo_id, attribution: attribution } if url
  end
end
