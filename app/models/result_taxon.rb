# frozen_string_literal: true

class ResultTaxon < ApplicationRecord
  TAXON_RANK = %w[
    superkingdom kingdom phylum class order family genus species
  ].freeze

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

  def sources_display
    return if result_sources.blank?
    result_sources.map do |source|
      id, primer = source.split('|')
      next if primer.blank?

      project = ResearchProject.where(id: id)
      next if project.blank?

      "#{project.first.name} - #{primer}"
    end.compact.join(', ')
  end

  private

  def query
    taxa.last
  end
end
