# frozen_string_literal: true

class NormalizeTaxa < ApplicationRecord
  as_enum :rank, %i[kingdom phylum class order family genus species], map: :string

  def name
    hierarchy[rank.to_s]
  end

  def taxa
    taxonomy_string.split(';').compact
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
