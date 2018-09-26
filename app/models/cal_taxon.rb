# frozen_string_literal: true

class CalTaxon < ApplicationRecord
  TAXON_RANK = %w[
    superkingdom kingdom phylum class order family genus species
  ].freeze
  TAXON_STATUS = ['accepted', 'doubtful', 'heterotypic synonym',
                  'homotypic synonym', 'synonym'].freeze

  validates :taxonRank, inclusion: { in: TAXON_RANK }

  def name
    original_hierarchy[taxonRank.to_s]
  end

  def original_taxonomy
    original_taxonomy_phylum || original_taxonomy_superkingdom
  end

  def taxa
    original_taxonomy
      .split(';')
      .select { |i| i != 'NA' && i.present? }
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
end
