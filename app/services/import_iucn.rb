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

    UpdateIucnStatusJob.perform_later(data, taxon)
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

  def update_iucn_status(data, taxon)
    status = IucnStatus::CATEGORIES[data[:category].to_sym]
    resource = ExternalResource.find_by(ncbi_id: taxon.id)
    iucn_data = { iucn_status: status, iucn_id: data[:taxonid] }

    if resource.present?
      return if resource.iucn_status.present?
      resource.update(iucn_data)
    else
      ExternalResource.create(iucn_data.merge(ncbi_id: taxon.id))
    end
  end

  private

  def find_taxon(data)
    rank = find_rank(data)
    canonical_name = form_canonical_name(data)
    NcbiNode.where(canonical_name: canonical_name, rank: rank).first
  end
end
