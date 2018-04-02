# frozen_string_literal: true

class NormalizeTaxa < ApplicationRecord
  as_enum :rank, %i[kingdom phylum class order family genus species], map: :string

  def name
    hierarchy[rank.to_s]
  end

  def taxa
    taxonomy_string.split(';').compact
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

  def inat_link
    "https://www.inaturalist.org/taxa/search?utf8=%E2%9C%93&q=#{query}"
  end

  def ncbi_link
    "https://www.ncbi.nlm.nih.gov/Taxonomy/Browser/wwwtax.cgi?name=#{query}"
  end

  def query
    taxa.last
  end

  def kingdom
    hierarchy['kingdom']
  end

  def phylum
    hierarchy['phylum']
  end

  def className
    hierarchy['class']
  end

  def order
    hierarchy['order']
  end

  def family
    hierarchy['family']
  end

  def genus
    hierarchy['genus']
  end

  def species
    hierarchy['species']
  end
end
