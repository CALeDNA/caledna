# frozen_string_literal: true

class Taxon < ApplicationRecord
  has_many :vernaculars, foreign_key: 'taxonID'
  has_many :asvs, foreign_key: 'taxonID'
  has_many :multimedia, foreign_key: 'taxonID'

  scope :valid, -> { where(taxonomicStatus: 'accepted') }

  def common_name
    names = vernaculars.where(language: :en)
                       .pluck(:vernacularName)
                       .map(&:downcase).uniq
    names.join(', ') if names.present?
  end

  # rubocop:disable Metrics/LineLength, Metrics/AbcSize
  # rubocop:disable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
  def taxonomy_tree
    tree = []
    tree.push(name: :kingdom, value: kingdom , id: hierarchy['kingdom']) if kingdom.present?;
    tree.push(name: :phylum, value: phylum, id: hierarchy['phylum']) if phylum.present?
    tree.push(name: :class, value: className, id: hierarchy['class']) if className.present?
    tree.push(name: :order, value: order, id: hierarchy['order']) if order.present?
    tree.push(name: :family, value: family, id: hierarchy['family']) if family.present?
    tree.push(name: :genus, value: genus, id: hierarchy['genus']) if genus.present?
    tree.push(name: :species, value: specificEpithet, id: hierarchy['species']) if specificEpithet.present?
    tree.push(name: :subspecies, value: infraspecificEpithet, id: hierarchy['subspecies']) if infraspecificEpithet.present?
    tree
  end
  # rubocop:enable Metrics/LineLength, Metrics/AbcSize,
  # rubocop:enable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity

  def image
    inaturalist_photo || gbif_photo
  end

  def inaturalist_link
    return if inaturalist_record.blank?
    id = inaturalist_record['id']
    name = inaturalist_record['name']
    "https://www.inaturalist.org/taxa/#{id}-#{name}"
  end

  def wikipedia_link
    return if inaturalist_record.blank?
    inaturalist_record['wikipedia_url']
  end

  def gbif_link
    "https://www.gbif.org/species/#{taxonID}"
  end

  def eol_link
    return if eol_record.blank?
    eol_record['link']
  end

  private

  def gbif_photo
    photo = multimedia.select(&:image?).first
    return if photo.blank?

    {
      url: photo.identifier,
      attribution:
        photo.rightsHolder ? "#{photo.publisher}: #{photo.rightsHolder}" : photo.publisher
    }
  end

  def inaturalist_photo
    return if inaturalist_record.blank?
    return if inaturalist_record['default_photo'].blank?

    {
      url: inaturalist_record['default_photo']['medium_url'],
      attribution: inaturalist_record['default_photo']['attribution'],
    }
  end

  def inaturalist_taxa
    inat = ::InaturalistApi.new(canonicalName)
    @inat_taxa ||= inat.taxa
  end

  def inaturalist_record
    JSON.parse(inaturalist_taxa.body)['results'].first
  end

  def eol_taxa
    service = ::EolApi.new
    @eol_taxa ||= service.taxa(canonicalName)
  end

  def eol_record
    @eol_record ||= JSON.parse(eol_taxa.body)['results'].last
  end
end
