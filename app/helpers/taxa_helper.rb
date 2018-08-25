# frozen_string_literal: true

module TaxaHelper
  def self.links(taxon)
    NcbiNode::LINKS.map { |link| taxon.send(link) }
  end

  # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
  def self.format_matching_taxa(taxa)
    max_limit = 25
    taxa_array = taxa.gsub(/[{}"]/, '').split(',')
    helpers = ActionController::Base.helpers

    results = "#{helpers.pluralize(taxa_array.length, 'match')}<br>"
    results += taxa_array.take(max_limit).map do |taxon|
      name, id = taxon.split(' | ')
      path = Rails.application.routes.url_helpers.taxon_path(id: id)
      helpers.link_to(name, path)
    end.join(', ')
    results += '...' if taxa_array.length > max_limit
    results
  end
  # rubocop:enable Metrics/MethodLength, Metrics/AbcSize
end
