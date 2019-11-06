# frozen_string_literal: true

module TaxaHelper
  def self.links(taxon)
    NcbiNode::LINKS.map { |link| taxon.send(link) }
  end

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
