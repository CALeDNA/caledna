# frozen_string_literal: true

class ImportIucn
  include HTTParty
  require 'uri'

  base_uri 'apiv3.iucnredlist.org/api/v3'

  def initialize
    @options = { query: { token: ENV.fetch('IUCN_TOKEN') } }
  end

  def connect
    self.class.get('/country/getspecies/US', @options)
  end

  def update_iucn_status(hash)
    data = hash.with_indifferent_access
    taxon = find_taxon(data)
    return if taxon.blank?

    taxon.update(iucn_status: data[:category], iucn_taxonid: data[:taxonid])
  end

  def form_canonical_name(data)
    if data[:rank].nil?
      data[:scientific_name]
    else
      species = data[:scientific_name].split(data[:rank]).first.strip
      "#{species} #{data[:subspecies]}"
    end
  end

  def find_rank(data)
    case data[:rank]
    when 'var.'
      'variety'
    when 'subsp.', 'ssp.'
      'subspecies'
    else
      'species'
    end
  end

  private

  def find_taxon(data)
    rank = find_rank(data)
    canonical_name = form_canonical_name(data)
    # TODO: decide whether to switch to NcbiNode
    Taxon.where(canonicalName: canonical_name, taxonRank: rank).first
  end
end
