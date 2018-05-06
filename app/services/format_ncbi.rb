# frozen_string_literal: true

module FormatNcbi
  def update_lineages
    nodes = NcbiNode.where('parent_taxon_id = 1 AND taxon_id != 1')

    nodes.each do |node|
      node.lineage = []
      node.lineage << [node.taxon_id, node.canonical_name, node.rank]
      node.save
      update_lineage(node)
    end
  end

  def insert_canonical_name
    NcbiNode.find_each do |node|
      name = NcbiName.find_by(taxon_id: node.id, name_class: 'scientific name')
      next if name.blank?
      node.update(canonical_name: name.name)
    end
  end

  private

  # rubocop:disable Metrics/AbcSize
  def update_lineage(parent_node)
    child_nodes = NcbiNode.where(parent_taxon_id: parent_node.taxon_id)
    return if child_nodes.blank?

    child_nodes.each do |child|
      child.lineage = [] if child.lineage.blank?
      parent_node.lineage.each { |n| child.lineage << n }
      child.lineage << [child.taxon_id, child.canonical_name, child.rank]
      child.save
      update_lineage(child)
    end
  end
  # rubocop:enable Metrics/AbcSize
end
