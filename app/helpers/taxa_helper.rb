# frozen_string_literal: true

module TaxaHelper
  def self.links(taxon)
    NcbiNode::LINKS.map { |link| taxon.send(link) }
  end

  def self.format_matching_taxa(taxa)
    max_limit = 25
    taxa_array = taxa.gsub(/[{}"]/, '').split(',')

    results = taxa_array.take(max_limit).map do |taxon|
      name, id = taxon.split(' | ')
      path = Rails.application.routes.url_helpers.taxon_path(id: id)
      ActionController::Base.helpers.link_to(name, path)
    end.join(', ')

    if taxa_array.length > max_limit
      results += " ...#{taxa_array.length} matches"
    end
    results
  end
end
