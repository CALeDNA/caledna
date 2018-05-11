# frozen_string_literal: true

module FormatNcbi
  def valid_rank?(node)
    node.rank != 'no rank'
  end

  def create_taxonomy_strings
    nodes = NcbiNode.where('parent_taxon_id = 1 AND taxon_id != 1')
    nodes.each do |node|
      node.full_taxonomy_string = node.canonical_name
      node.save
      create_taxonomy_string(node)
    end
  end

  def create_taxonomy_string(parent_node)
    child_nodes = NcbiNode.where(parent_taxon_id: parent_node.taxon_id)
    return if child_nodes.blank?

    child_nodes.each do |child|
      short = create_short_taxonomy_string(parent_node, child)
      child.short_taxonomy_string = short

      full = "#{parent_node.full_taxonomy_string};#{child.canonical_name}"
      child.full_taxonomy_string = full

      child.save

      create_taxonomy_string(child)
    end
  end

  def update_lineages
    nodes = NcbiNode.where('parent_taxon_id = 1 AND taxon_id != 1')

    nodes.each do |node|
      node.lineage = []
      node.lineage << [node.taxon_id, node.canonical_name, node.rank]
      node.hierarchy = { "#{node.rank}": node.taxon_id } if valid_rank?(node)
      node.save

      update_lineage_hierarchy(node)
    end
  end

  def insert_canonical_name
    NcbiNode.find_each do |node|
      name = NcbiName.find_by(taxon_id: node.id, name_class: 'scientific name')
      next if name.blank?
      node.update(canonical_name: name.name)
    end
  end

  def create_citations_nodes
    NcbiCitation.find_each do |cite|
      list = cite.taxon_id_list
      next if list.blank?

      taxon_ids = list.split(' ')
      taxon_ids.each do |id|
        NcbiCitationNode
          .create(ncbi_node_id: id.to_i, ncbi_citation_id: cite.id)
      end
    end
  end

  private

  def format_short_taxonomy_string(parent_node, child, ranks)
    temp = "#{parent_node.short_taxonomy_string};"
    temp += ';' while temp.split(';', -1).count < ranks.index(child.rank) + 1
    "#{temp}#{child.canonical_name}"
  end

  def create_short_taxonomy_string(parent_node, child)
    ranks = %w[phylum class order family genus species]

    if ranks.include?(child.rank)
      if parent_node.short_taxonomy_string.blank?
        child.canonical_name
      else
        format_short_taxonomy_string(parent_node, child, ranks)
      end
    elsif parent_node.short_taxonomy_string.present?
      parent_node.short_taxonomy_string
    end
  end

  def update_lineage_hierarchy(parent_node)
    child_nodes = NcbiNode.where(parent_taxon_id: parent_node.taxon_id)
    return if child_nodes.blank?

    child_nodes.each do |child|
      child = update_lineage(parent_node, child)
      child = update_hierarchy(parent_node, child)
      child.save

      update_lineage_hierarchy(child)
    end
  end

  def update_lineage(parent_node, child)
    child.lineage = [] if child.lineage.blank?
    parent_node.lineage.each { |n| child.lineage << n }
    child.lineage << [child.taxon_id, child.canonical_name, child.rank]
    child
  end

  def update_hierarchy(parent_node, child)
    if valid_rank?(child)
      child.hierarchy =
        parent_node.hierarchy.merge("#{child.rank}": child.taxon_id)
    else
      child.hierarchy = parent_node.hierarchy
    end
    child
  end
end
