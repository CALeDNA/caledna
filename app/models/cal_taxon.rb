# frozen_string_literal: true

class CalTaxon < ApplicationRecord
  TAXON_RANK = %w[
    superkingdom kingdom phylum class order family genus species
  ].freeze

  validates :taxon_rank, inclusion: { in: TAXON_RANK }

  def name
    hierarchy[taxon_rank.to_s]
  end

  def original_taxonomy
    original_taxonomy_string
  end

  def taxa
    original_taxonomy_string
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
end
