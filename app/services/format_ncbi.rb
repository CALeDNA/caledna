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

  def create_hierarchy_names_info
    nodes = NcbiNode.where('parent_taxon_id = 1 AND taxon_id != 1')

    nodes.each do |node|
      if valid_rank?(node)
        node.hierarchy_names = { "#{node.rank}": node.canonical_name }
        node.save
      end

      create_hierarchy_names(node)
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

  def create_common_names
    sql = <<-SQL
      name_class = 'common name' OR
      name_class = 'genbank common name'
    SQL

    NcbiName.where(sql).find_each do |record|
      clean_name = record.name.delete("'")
      sql = <<-SQL
        UPDATE ncbi_nodes
        SET common_names = coalesce($1 || '|' || common_names, $1)
        WHERE ncbi_id = $2
      SQL
      binding = [[nil, clean_name], [nil, record.taxon_id]]

      conn.exec_query(sql, 'q', binding)
    end
  end

  def create_taxa_tree
    result = exec(sql_select_root_node)

    result.each do |node|
      name = node['canonical_name']
      rank = node['rank']
      id = node['taxon_id']

      ids = "{#{id}}"
      node['ids'] = ids

      ranks = "{#{rank}}"
      node['ranks'] = ranks

      names = "{#{name}}"
      node['names'] = names

      taxa_string = name
      node['full_taxonomy_string'] = taxa_string

      hierarchy = "{\"#{rank}\" : #{id}}"
      node['hierarchy'] = hierarchy

      hierarchy_names = "{\"#{rank}\" : \"#{name}\"}"
      node['hierarchy_names'] = hierarchy_names

      update_node_taxa_tree(ids, ranks, names, taxa_string, hierarchy, hierarchy_names, id)

      create_taxa_tree_for(node)
    end
  end

  private

  def conn
    @conn ||= ActiveRecord::Base.connection
  end

  def valid_rank?(node)
    node.rank != 'no rank'
  end

  def exec(sql, binding = nil)
    if binding.present?
      ActiveRecord::Base.connection.exec_query(sql, 'q', binding)
    else
      ActiveRecord::Base.connection.exec_query(sql)
    end
  end

  def append_array(field, value)
    field.gsub('}', ",#{value}}")
  end

  # ===================
  # create ids
  # ===================

  def sql_select_root_node
    <<-SQL
    SELECT taxon_id, parent_taxon_id, rank, ids, canonical_name
    FROM ncbi_nodes
    WHERE parent_taxon_id = 1 AND taxon_id != 1;
    SQL
  end

  def sql_select_node
    <<-SQL
    SELECT taxon_id, parent_taxon_id, rank, ids, canonical_name
    FROM ncbi_nodes
    WHERE parent_taxon_id = $1;
    SQL
  end

  def ncbi_nodes
    @ncbi_nodes ||= Arel::Table.new('ncbi_nodes')
  end

  def update_node_taxa_tree(ids, ranks, names, taxa_string, hierarchy, hierarchy_names, taxon_id)
    update_manager = Arel::UpdateManager.new
    update_manager.table(ncbi_nodes).where(ncbi_nodes[:taxon_id].eq(taxon_id))
    update_manager.set(
      [
        [ncbi_nodes[:ids], ids],
        [ncbi_nodes[:ranks], ranks],
        [ncbi_nodes[:names], names],
        [ncbi_nodes[:full_taxonomy_string], taxa_string],
        [ncbi_nodes[:hierarchy], hierarchy],
        [ncbi_nodes[:hierarchy_names], hierarchy_names]
      ]
    )
    sql = update_manager.to_sql

    exec(sql)
  end

  def create_taxa_tree_for(parent_node)
    child_nodes = exec(sql_select_node, [[nil, parent_node['taxon_id']]])
    return if child_nodes.count.zero?

    child_nodes.each do |child|
      name = child['canonical_name']
      rank = child['rank']
      id = child['taxon_id']

      ids = parent_node['ids'].gsub('}', ",#{id}}")
      child['ids'] = ids

      ranks = append_array(parent_node['ranks'], rank)
      child['ranks'] = ranks

      names = append_array(parent_node['names'], name)
      child['names'] = names

      taxa_string = parent_node['full_taxonomy_string'] + '|' + name
      child['full_taxonomy_string'] = taxa_string

      hierarchy = append_array(parent_node['hierarchy'], "\"#{rank}\" : #{id}")
      child['hierarchy'] = hierarchy

      hierarchy_names = append_array(
        parent_node['hierarchy_names'], "\"#{rank}\" : \"#{name}\""
      )
      child['hierarchy_names'] = hierarchy_names

      update_node_taxa_tree(ids, ranks, names, taxa_string, hierarchy,
                            hierarchy_names, id)

      create_taxa_tree_for(child)
    end
  end

  # ===================
  #
  # ===================

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

  def create_hierarchy_names(parent_node)
    child_nodes = NcbiNode.where(parent_taxon_id: parent_node.taxon_id)
    return if child_nodes.blank?

    child_nodes.each do |child|
      hierarchy = format_hierarchy_names(parent_node, child)
      child.hierarchy_names = hierarchy
      child.save

      create_hierarchy_names(child)
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

  def format_hierarchy_names(parent_node, child)
    if valid_rank?(child)
      parent_node.hierarchy_names.merge("#{child.rank}": child.canonical_name)
    else
      parent_node.hierarchy_names
    end
  end
end
