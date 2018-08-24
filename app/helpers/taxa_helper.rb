# frozen_string_literal: true

module TaxaHelper
  def self.links(taxon)
    NcbiNode::LINKS.map { |link| taxon.send(link) }
  end

  def self.format_matching_taxa(taxa)
    taxa_array = taxa.gsub(/[{}"]/, '').split(',')

    taxa_array.map do |taxon|
      name, id = taxon.split(' | ')
      path = Rails.application.routes.url_helpers.taxon_path(id: id)
      ActionController::Base.helpers.link_to(name, path)
    end.join(', ')
  end
end
