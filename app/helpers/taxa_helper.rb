# frozen_string_literal: true

module TaxaHelper
  def self.links(taxon)
    NcbiNode::LINKS.map { |link| taxon.send(link) }
  end
end
