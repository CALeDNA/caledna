# frozen_string_literal: true

# rubocop:disable Metrics/ClassLength
class Taxon < ApplicationRecord
  has_many :vernaculars, foreign_key: 'taxonID'
  has_many :asvs, foreign_key: 'taxonID'
  has_many :multimedia, foreign_key: 'taxonID'
  has_many :highlights, as: :highlightable

  scope :valid, -> { where(taxonomicStatus: 'accepted') }

  def common_names(parenthesis = true)
    names = vernaculars.english.pluck(:vernacularName)
                       .map(&:titleize).uniq
    return if names.blank?
    parenthesis ? "(#{common_names_string(names)})" : common_names_string(names)
  end

  def taxa_dataset
    ::TaxaDataset.find_by(datasetID: datasetID)
  end

  # rubocop:disable Metrics/LineLength, Metrics/AbcSize
  # rubocop:disable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
  def taxonomy_tree
    tree = []
    tree.push(name: :kingdom, value: kingdom, id: hierarchy['kingdom']) if kingdom.present?
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

  def iucn_link
    return if iucn_record.blank?
    "http://www.iucnredlist.org/details/#{iucn_record['taxonid']}"
  end

  def conservation_status?
    return unless taxonRank == 'species' || taxonRank == 'subspecies'
    iucn_record.present?
  end

  def conservation_status
    return if iucn_record.blank?
    ::IucnApi::CATEGORIES[iucn_record['category'].to_sym]
  end

  def synonyms
    Taxon.where(acceptedNameUsageID: taxonID)
  end

  private

  def common_names_string(names)
    max = 3
    names.count > max ? "#{names.take(max).join(', ')}..." : names.join(', ')
  end

  def gbif_photo
    photo = multimedia.select(&:image?).first
    return if photo.blank?
    {
      url: photo.identifier,
      attribution: photo.rightsHolder,
      source: photo.publisher,
      taxa_url: gbif_link
    }
  end

  def inaturalist_photo
    return if inaturalist_record.blank?
    return if inaturalist_record['default_photo'].blank?
    {
      url: inaturalist_record['default_photo']['medium_url'],
      attribution: inaturalist_record['default_photo']['attribution'],
      source: 'iNaturalist',
      taxa_url: inaturalist_link
    }
  end

  def inaturalist_taxa
    puts '---- inat'

    inat = ::InaturalistApi.new(canonicalName)
    @inaturalist_taxa ||= inat.taxa
  end

  def inaturalist_record
    @inaturalist_record ||= JSON.parse(inaturalist_taxa.body)['results'].first
  end

  def eol_taxa
    puts '---- eol'

    service = ::EolApi.new
    @eol_taxa ||= service.taxa(canonicalName)
  end

  def eol_record
    @eol_record ||= JSON.parse(eol_taxa.body)['results'].last
  end

  def iucn_species
    puts '---- iucn'
    service = ::IucnApi.new
    @iucn_species ||= service.species(canonicalName)
  end

  def iucn_record
    @iucn_record ||= JSON.parse(iucn_species.body)['result'].first
  end
end
# rubocop:enable Metrics/ClassLength
