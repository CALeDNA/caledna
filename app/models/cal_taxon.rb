# frozen_string_literal: true

class CalTaxon < ApplicationRecord
  TAXON_RANK = %w[kingdom phylum class order family genus species].freeze
  TAXON_STATUS = ['accepted', 'doubtful', 'heterotypic synonym',
                  'homotypic synonym', 'synonym'].freeze

  validates :kingdom, :taxonRank, :taxonomicStatus, :hierarchy,
            presence: true, on: :update
  validates :parentNameUsageID,
            presence: { message: ': Must use search to find parent taxonomy' },
            on: :update
  validates :canonicalName,
            presence: { message: ': Must select a taxon rank' },
            on: :update
  validate :at_least_one_taxa, on: :update
  validates :taxonomicStatus, inclusion: { in: TAXON_STATUS }, on: :update
  validates :taxonRank, inclusion: { in: TAXON_RANK }
  validates :canonicalName, uniqueness: { scope: :kingdom }, on: :update

  def name
    original_hierarchy[taxonRank.to_s]
  end

  def taxa
    original_taxonomy.split(';').compact
  end

  def col_link
    "http://www.catalogueoflife.org/col/search/all/key/#{query}"
  end

  def eol_link
    "http://eol.org/search?q=#{query}"
  end

  def gbif_link
    "https://www.gbif.org/species/search?q=#{query}"
  end

  def ncbi_link
    "https://www.ncbi.nlm.nih.gov/Taxonomy/Browser/wwwtax.cgi?name=#{query}"
  end

  def query
    taxa.last
  end

  def h_kingdom
    original_hierarchy['kingdom']
  end

  def h_phylum
    original_hierarchy['phylum']
  end

  def h_class_name
    original_hierarchy['class']
  end

  def h_order
    original_hierarchy['order']
  end

  def h_family
    original_hierarchy['family']
  end

  def h_genus
    original_hierarchy['genus']
  end

  def h_species
    original_hierarchy['species']
  end

  private

  def at_least_one_taxa
    fields = [phylum, className, order, family, genus, specificEpithet]
    return if fields.any?(&:present?)
    errors.add(:at_least_one_taxa,
               ': At least one taxonomy field must be entered')
  end
end
