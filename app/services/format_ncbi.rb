# frozen_string_literal: true

module FormatNcbi
  def create_taxonomy_strings
    nodes = NcbiNode.where('parent_taxon_id = 1 AND taxon_id != 1')
    nodes.each do |node|
      node.full_taxonomy_string = node.canonical_name
      node.save
      create_taxonomy_string(node)
    end
  end

  def create_lineage_info
    nodes = NcbiNode.where('parent_taxon_id = 1 AND taxon_id != 1')

    nodes.each do |node|
      node.lineage = []
      node.lineage << [node.taxon_id, node.canonical_name, node.rank]
      node.hierarchy = { "#{node.rank}": node.taxon_id } if valid_rank?(node)
      node.save

      create_lineage_hierarchy(node)
    end
  end

  def create_canonical_name
    NcbiNode.find_each do |node|
      name = NcbiName.find_by(taxon_id: node.id, name_class: 'scientific name')
      next if name.blank?
      node.update(canonical_name: name.name)
    end
  end

  def create_alt_names
    sql = "name_class = 'common name' OR " \
      "name_class = 'genbank common name' OR " \
      "name_class = 'genbank synonym'  OR " \
      "name_class = 'synonym' OR " \
      "name_class = 'equivalent name'"

    NcbiName.where(sql).all.each do |name|
      clean_name = name.name.delete("'")
      sql = 'UPDATE ncbi_nodes SET alt_names =  ' \
        "coalesce('#{clean_name}' || ' | ' || alt_names, '#{clean_name}') " \
        "WHERE taxon_id = #{name.taxon_id} "
      ActiveRecord::Base.connection.execute(sql)
    end
  end

  def create_ids
    nodes = NcbiNode.where('parent_taxon_id = 1 AND taxon_id != 1')
    nodes.each do |node|
      node.ids = []
      node.ids << node.taxon_id
      node.save
      create_ids_for(node)
    end
  end

  private

  def valid_rank?(node)
    node.rank != 'no rank'
  end

  def create_ids_for(parent_node)
    child_nodes = NcbiNode.where(parent_taxon_id: parent_node.taxon_id)
    return if child_nodes.blank?

    child_nodes.each do |child|
      ids = create_ids_array(parent_node, child)
      child.ids = ids
      child.save

      create_ids_for(child)
    end
  end

  def create_ids_array(parent_node, child)
    ids = parent_node.ids.dup
    ids << child.taxon_id
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

  def format_short_taxonomy_string(parent_node, child, ranks)
    temp = "#{parent_node.short_taxonomy_string};"
    # NOTE: adds ';;' for missing ranks
    temp += ';' while temp.split(';', -1).count < ranks.index(child.rank) + 1
    "#{temp}#{child.canonical_name}"
  end

  def create_lineage_hierarchy(parent_node)
    child_nodes = NcbiNode.where(parent_taxon_id: parent_node.taxon_id)
    return if child_nodes.blank?

    child_nodes.each do |child|
      lineage = create_lineage(parent_node, child)
      child.lineage = lineage
      hierarchy = create_hierarchy(parent_node, child)
      child.hierarchy = hierarchy
      child.save

      create_lineage_hierarchy(child)
    end
  end

  def create_lineage(parent_node, child)
    lineage = []
    parent_node.lineage.each { |l| lineage << l }
    lineage << [child.taxon_id, child.canonical_name, child.rank]
  end

  def create_hierarchy(parent_node, child)
    if valid_rank?(child)
      parent_node.hierarchy.merge("#{child.rank}": child.taxon_id)
    else
      parent_node.hierarchy
    end
  end
end
