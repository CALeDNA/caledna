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

  def process_iucn_status(hash)
    data = hash.with_indifferent_access
    taxon = find_taxon(data)
    return if taxon.blank?

    update_iucn_status(data, taxon)
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

  def update_iucn_status(data, taxon)
    status = IucnStatus::CATEGORIES[data[:category].to_sym]
    taxon.iucn_status = status
    taxon.save
  end

  def find_taxon(data)
    rank = find_rank(data)
    canonical_name = form_canonical_name(data)
    NcbiNode.where('lower(canonical_name) = ?', canonical_name.downcase)
            .where(rank: rank).first
  end
end
