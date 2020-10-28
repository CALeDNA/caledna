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

  def occurence_by_taxon(taxon_id)
    self.class.get('/occurrence/search', query: { taxonKey: taxon_id })
  end

  def inat_occurrence_by_taxon(taxon_id)
    self.class.get(
      '/occurrence/search',
      query: { taxonKey: taxon_id, mediaType: 'StillImage', limit: 1,
               datasetKey: '50c9509d-22c7-4a22-a47d-8c48425ef4a7' }
    )
  end
end
