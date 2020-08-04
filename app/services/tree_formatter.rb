# frozen_string_literal: true

module TreeFormatter
  def fetch_nested_taxa_tree_for_sample(id)
    # res = PgConnect.execute(taxa_for_sample_sql, [id, id])
    bindings = [[nil, id], [nil, id]]
    res = conn.exec_query(taxa_for_sample_sql, 'q', bindings)
    tree_objects = create_nested_tree_objects(res.entries)
    # create_nested_tree(tree_objects)
  end

  private

  def conn
    ActiveRecord::Base.connection
  end

  def taxa_for_sample_sql
    <<~SQL
      SELECT ncbi_nodes.taxon_id,ncbi_nodes.canonical_name,
      ncbi_divisions.name as domain, ncbi_divisions.id as domain_id,
      ncbi_nodes.rank,
      ncbi_nodes.hierarchy,
      common_names
      FROM ncbi_nodes
      LEFT JOIN ncbi_divisions ON ncbi_divisions.id = ncbi_nodes.cal_division_id
      WHERE taxon_id IN (
        SELECT DISTINCT unnest(ids)
        FROM asvs
        JOIN ncbi_nodes ON asvs.taxon_id = ncbi_nodes.taxon_id
        WHERE sample_id = $1
        and ncbi_nodes.cal_division_id != 11
      )
      AND rank IN ('species', 'genus', 'family', 'order', 'class', 'phylum')

      UNION

      SELECT ncbi_nodes.taxon_id,ncbi_nodes.canonical_name,
      'Environmental samples' as domain, 11 as domain_id,
      ncbi_nodes.rank,
      ncbi_nodes.hierarchy,
      common_names
      FROM ncbi_nodes
      LEFT JOIN ncbi_divisions ON ncbi_divisions.id = ncbi_nodes.cal_division_id
      WHERE taxon_id IN (
        SELECT DISTINCT unnest(ids)
        FROM asvs
        JOIN ncbi_nodes ON asvs.taxon_id = ncbi_nodes.taxon_id
        WHERE sample_id = $2
        and ncbi_nodes.cal_division_id = 11

      )
      AND rank IN ('species', 'genus', 'family', 'order', 'class', 'phylum')

      ;
    SQL
  end

  def create_nested_tree_objects(taxa)
    ranks = %w[species genus family order class phylum]
    tree_objects = []
    domains = {}

    taxa.each do |record|
      domains[record['domain_id']] = record['domain']
      parent_id = get_parent_id(record, ranks)

      tree_objects << {
        name: record['canonical_name'],
        parent_id: parent_id,
        id: record['taxon_id'],
        rank: record['rank'],
        common_names: record['common_names']
      }
    end

    tree_objects << { name: '* no kingdom', id: 'd_', parent_id: 'Life',
                      rank: 'kingdom' }

    domains.each do |id, name|
      next if id.blank?
      tree_objects << {
        name: name,
        id: "d_#{id}",
        parent_id: 'Life',
        rank: 'kingdom'
      }
    end
    tree_objects << { name: 'Life', id: 'Life', common_name: nil, rank: nil,
                      parent_id: nil }
    tree_objects
  end

  def create_nested_tree(taxa)
    taxa_hash = {}
    taxa.each do |taxon|
      taxa_hash[taxon[:id].to_s] = taxon
    end

    tree_data = []
    taxa.each do |taxon|
      parent = taxa_hash[taxon[:parent_id].to_s]
      if parent
        parent[:children] = [] if parent[:children].blank?
        parent[:children] << taxon

        parent[:children].sort_by! { |child| child[:name] }
      else
        tree_data << taxon
      end
    end
    tree_data.sort_by! { |child| child[:name] }
  end

  def get_parent_id(record, ranks)
    record['hierarchy'] = JSON.parse(record['hierarchy'])
    rank = record['rank']
    parent_rank_index = ranks.index(rank) + 1
    parent_rank = ranks[parent_rank_index]
    parent_id = record['hierarchy'][parent_rank]

    if rank == 'phylum'
      parent_id = "d_#{record['domain_id']}"
    else
      while parent_id.blank?
        parent_rank_index += 1
        parent_rank = ranks[parent_rank_index]
        parent_id = record['hierarchy'][parent_rank]

        parent_id = "d_#{record['domain_id']}" if parent_rank_index > 5
      end
    end
    parent_id
  end
end
