# frozen_string_literal: true

class InatObservationSerializer
  include FastJsonapi::ObjectSerializer
  attributes :observation_id, :latitude, :longitude, :common_name,
             :image_url, :taxon_id, :url, :canonical_name, :rank

  attribute :rank do |object|
    object.inat_taxon.rank
  end

  attribute :canonical_name do |object|
    object.inat_taxon.canonical_name
  end

  attribute :common_name do |object|
    object.inat_taxon.common_name
  end
end
