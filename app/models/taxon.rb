# frozen_string_literal: true

# rubocop:disable Metrics/ClassLength
class Taxon < ApplicationRecord
  # taxonomicStatus: [accepted, doubtful, heterotypic synonym,
  # homotypic synonym, misapplied, proparte synonym, synonym]

  # taxonRank: kingdom phylum class order family genus species subspecies
  # variety unranked form

  IUCN_CATEGORIES = {
    EX: 'Extinct',
    EW: 'Extinct in the Wild',
    CR: 'Critically Endangered',
    EN: 'Endangered',
    VU: 'Vulnerable',
    NT: 'Near Threatened',
    LC: 'Least Concern',
    DD: 'Data Deficient',
    NE: 'Not Evaluated'
  }.freeze

  has_many :vernaculars, foreign_key: 'taxonID'
  has_many :asvs, foreign_key: 'taxonID'
  has_many :multimedia, foreign_key: 'taxonID'
  has_many :highlights, as: :highlightable
  belongs_to :taxa_dataset, foreign_key: 'datasetID'
  validates :taxonID, presence: true

  scope :valid, -> { where(taxonomicStatus: 'accepted') }

  def common_names(parenthesis = true)
    names = vernaculars.select { |v| v.language == 'en' }
                       .pluck(:vernacularName)
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
    tree.push(name: :kingdom, value: kingdom_display, id: hierarchy['kingdom']) if kingdom.present?
    tree.push(name: :phylum, value: phylum_display, id: hierarchy['phylum']) if phylum.present?
    tree.push(name: :class, value: class_name_display, id: hierarchy['class']) if className.present?
    tree.push(name: :order, value: order_display, id: hierarchy['order']) if order.present?
    tree.push(name: :family, value: family_display, id: hierarchy['family']) if family.present?
    tree.push(name: :genus, value: genus_display, id: hierarchy['genus']) if genus.present?
    tree.push(name: :species, value: species_display, id: hierarchy['species']) if specificEpithet.present?
    tree.push(name: :subspecies, value: subspecies_display, id: hierarchy['subspecies']) if infraspecificEpithet.present?
    tree
  end
  # rubocop:enable Metrics/LineLength, Metrics/AbcSize,
  # rubocop:enable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity

  def taxonomy_string
    taxonomy_tree.map { |taxon| taxon[:value] }.join(', ')
  end

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
    return unless conservation_status?
    "http://www.iucnredlist.org/details/#{iucn_taxonid}"
  end

  def conservation_status?
    return unless taxonRank == 'species' || taxonRank == 'subspecies'
    conservation_status.present?
  end

  def conservation_status
    return if iucn_status.blank?
    IUCN_CATEGORIES[iucn_status.to_sym]
  end

  def threatened?
    statuses = %w[EX EW CR EN VU NT]
    statuses.include?(iucn_status)
  end

  def synonyms
    Taxon.where(acceptedNameUsageID: taxonID)
  end

  def accepted_taxon
    Taxon.find_by(taxonID: acceptedNameUsageID)
  end

  private

  def kingdom_display
    taxonRank == 'kingdom' ? canonicalName : kingdom
  end

  def phylum_display
    taxonRank == 'phylum' ? canonicalName : phylum
  end

  def class_name_display
    taxonRank == 'class' ? canonicalName : className
  end

  def order_display
    taxonRank == 'order' ? canonicalName : order
  end

  def family_display
    taxonRank == 'family' ? canonicalName : family
  end

  def genus_display
    if taxonRank == 'species' || taxonRank == 'genus' ||
       taxonRank == 'subspecies'
      genericName
    else
      genus
    end
  end

  def species_display
    "#{genericName} #{specificEpithet}"
  end

  def subspecies_display
    canonicalName
  end

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
    response = JSON.parse(eol_taxa.body)
    # return if response.first['error'].present?
    @eol_record ||= response['results'].last
  end
end
# rubocop:enable Metrics/ClassLength
