# frozen_string_literal: true

module FormatNcbi
  # rubocop:disable Metrics/MethodLength
  def create_alt_names
    sql = <<-SQL
      name_class = 'common name' OR
      name_class = 'genbank common name' OR
      name_class = 'genbank synonym'  OR
      name_class = 'synonym' OR
      name_class = 'equivalent name'
    SQL

    NcbiName.where(sql).find_each do |name|
      clean_name = name.name.delete("'")
      sql = <<-SQL
        UPDATE ncbi_nodes
        SET alt_names = coalesce($1 || ' | ' || alt_names, $1)
        WHERE ncbi_id = $2
      SQL
      binding = [[nil, clean_name], [nil, name.taxon_id]]

      conn.exec_query(sql, 'q', binding)
    end
  end
  # rubocop:enable Metrics/MethodLength

  # rubocop:disable Metrics/MethodLength
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
  # rubocop:enable Metrics/MethodLength

  # rubocop:disable Metrics/MethodLength
  def create_taxa_tree
    nodes = NcbiNode.where('parent_taxon_id = 1 AND ncbi_id != 1')

    nodes.each do |node|
      name = node.canonical_name
      rank = node.rank
      id = node.taxon_id

      node.ids = [id]
      node.ranks = [rank]
      node.names = [name]
      node.full_taxonomy_string = name

      if valid_rank?(node)
        node.hierarchy = { rank => id }
        node.hierarchy_names = { rank => name }
      end

      raise(StandardError, 'invalid NcbiNode') unless node.valid?
      node.save

      create_taxa_tree_for(node)
    end
  end
  # rubocop:enable Metrics/MethodLength

  private

  def conn
    @conn ||= ActiveRecord::Base.connection
  end

  def valid_rank?(node)
    node.rank != 'no rank'
  end

  def append_array(field, value)
    copy = field.dup
    copy << value
  end

  # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
  def create_taxa_tree_for(parent_node)
    child_nodes = NcbiNode.where(parent_taxon_id: parent_node.ncbi_id)
                          .where(source: 'NCBI')
    return if child_nodes.blank?

    child_nodes.each do |node|
      name = node.canonical_name
      rank = node.rank
      id = node.taxon_id

      node.ids = append_array(parent_node.ids, id)
      node.ranks = append_array(parent_node.ranks, rank)
      node.names = append_array(parent_node.names, name)
      node.full_taxonomy_string = parent_node.full_taxonomy_string. + '|' + name

      if valid_rank?(node)
        node.hierarchy = parent_node.hierarchy.merge(rank => id)
        node.hierarchy_names = parent_node.hierarchy_names.merge(rank => name)
      else
        node.hierarchy = parent_node.hierarchy
        node.hierarchy_names = parent_node.hierarchy_names
      end

      raise(StandardError, 'invalid NcbiNode') unless node.valid?
      node.save

      create_taxa_tree_for(node)
    end
  end
  # rubocop:enable Metrics/MethodLength, Metrics/AbcSize
end
