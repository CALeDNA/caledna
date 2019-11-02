# frozen_string_literal: true

module TaxaHelper
  def self.links(taxon)
    NcbiNode::LINKS.map { |link| taxon.send(link) }
  end

  # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
  def self.format_matching_taxa(taxa)
    max_limit = 25

    # https://stackoverflow.com/a/17271822
    # use YAML.safe_load  to convert string arrays from raw sql queries
    # into arrays.
    begin
      taxa_array = YAML.safe_load(taxa)
    rescue StandardError => e
      puts "---- YAML error #{e}}"
      return
    end

    helpers = ActionController::Base.helpers

    results = "#{helpers.pluralize(taxa_array.length, 'match')}<br>"
    results += taxa_array.keys.take(max_limit).map do |taxon|
      name, id = taxon.split(' | ')
      path = Rails.application.routes.url_helpers.taxon_path(id: id)
      helpers.link_to(name, path)
    end.join(', ')
    results += ' ...' if taxa_array.length > max_limit
    results
  end
  # rubocop:enable Metrics/MethodLength, Metrics/AbcSize

  def self.show_kingdom_icon?(division_name)
    (['Environmental samples', 'Viruses'] + NcbiDivision::SEVEN_KINGDOMS)
      .include?(division_name)
  end

  def self.kingdom_icon(division_name)
    return unless (['Environmental samples', 'Viruses'] +
      NcbiDivision::SEVEN_KINGDOMS).include?(division_name)

    "taxa_icons/#{division_name.downcase.tr(' ', '_')}.png"
  end
end
