# frozen_string_literal: true

module AsvTreeFormatter
  include CheckWebsite

  # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity
  # rubocop:disable Metrics/PerceivedComplexity, Metrics/MethodLength
  def create_taxon_object(taxon)
    rank = taxon.rank
    domain = taxon.domain

    k = taxon.domain
    p = taxon.hierarchy_names['phylum']
    c = taxon.hierarchy_names['class']
    o = taxon.hierarchy_names['order']
    f = taxon.hierarchy_names['family']
    g = taxon.hierarchy_names['genus']
    sp = taxon.hierarchy_names['species']

    k_id = format_taxon_id(taxon.domain_id, domain)
    p_id = format_taxon_id(taxon.hierarchy['phylum'], domain)
    c_id = format_taxon_id(taxon.hierarchy['class'], domain)
    o_id = format_taxon_id(taxon.hierarchy['order'], domain)
    f_id = format_taxon_id(taxon.hierarchy['family'], domain)
    g_id = format_taxon_id(taxon.hierarchy['genus'], domain)
    sp_id = format_taxon_id(taxon.hierarchy['species'], domain)

    results = {}

    if ['species'].include?(rank)
      results[:species] = sp
      results[:species_id] = sp_id
    end
    if %w[species genus].include?(rank)
      results[:genus] = g || format_blank_name(results[:species], 'genus')
      results[:genus_id] = g_id || format_blank_rank(results[:species_id], 'g')
    end
    if %w[species genus family].include?(rank)
      results[:family] = f || format_blank_name(results[:genus], 'family')
      results[:family_id] = f_id || format_blank_rank(results[:genus_id], 'f')
    end
    if %w[species genus family order].include?(rank)
      results[:order] = o || format_blank_name(results[:family], 'order')
      results[:order_id] = o_id || format_blank_rank(results[:family_id], 'o')
    end
    if %w[species genus family order class].include?(rank)
      results[:class] = c || format_blank_name(results[:order], 'class')
      results[:class_id] = c_id || format_blank_rank(results[:order_id], 'c')
    end
    if %w[species genus family order class phylum].include?(rank)
      results[:phylum] = p || format_blank_name(results[:class], 'phylum')
      results[:phylum_id] = p_id || format_blank_rank(results[:class_id], 'p')
    end
    if %w[species genus family order class phylum kingdom].include?(rank)
      results[:kingdom] = k
      results[:kingdom_id] = "k_#{k_id}"
    end

    results = results.reject { |_k, v| v.blank? }
    results[:common_name] =
      taxon.common_names.present? ? taxon.common_names.split('|').first : nil
    results[:original_rank] = rank

    results
  end
  # rubocop:enable Metrics/AbcSize, Metrics/CyclomaticComplexity
  # rubocop:enable Metrics/PerceivedComplexity, Metrics/MethodLength

  # rubocop:disable Metrics/MethodLength
  def create_tree_object(taxon_object, rank, parent_id, id)
    common_name = if taxon_object[:original_rank] == rank.to_s
                    taxon_object[:common_name]
                  end
    display_name = if common_name.present?
                     "#{taxon_object[rank]} (#{common_name})"
                   else
                     taxon_object[rank]
                   end
    parent_id = if rank == :phylum
                  taxon_object[:kingdom_id]
                else
                  taxon_object[parent_id]
                end
    # debugger
    {
      name: display_name,
      parent_id: parent_id,
      id: taxon_object[id],
      rank: rank
    }
  end
  # rubocop:enable Metrics/MethodLength

  # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity
  # rubocop:disable Metrics/PerceivedComplexity, Metrics/MethodLength
  def create_tree_objects(taxon_object, rank)
    objects = []

    if ['species'].include?(rank)
      objects << create_tree_object(taxon_object, :species, :genus_id,
                                    :species_id)
    end
    if %w[species genus].include?(rank)
      objects << create_tree_object(taxon_object, :genus, :family_id,
                                    :genus_id)
    end
    if %w[species genus family].include?(rank)
      objects << create_tree_object(taxon_object, :family, :order_id,
                                    :family_id)
    end
    if %w[species genus family order].include?(rank)
      objects << create_tree_object(taxon_object, :order, :class_id,
                                    :order_id)
    end
    if %w[species genus family order class].include?(rank)
      objects << create_tree_object(taxon_object, :class, :phylum_id,
                                    :class_id)
    end
    if %w[species genus family order class phylum].include?(rank)
      objects << create_tree_object(taxon_object, :phylum, :kingdom_id,
                                    :phylum_id)
    end
    if %w[species genus family order class phylum kingdom].include?(rank)
      objects << { name: taxon_object[:kingdom],
                   parent_id: 'Life',
                   id: taxon_object[:kingdom_id],
                   rank: :kingdom }
    end
    objects
  end
  # rubocop:enable Metrics/AbcSize, Metrics/CyclomaticComplexity
  # rubocop:enable Metrics/PerceivedComplexity, Metrics/MethodLength

  def fetch_asv_tree_for_sample(sample_id)
    taxa = fetch_asv_tree.where('ncbi_nodes.taxon_id IN '\
      '(SELECT DISTINCT taxon_id FROM asvs '\
      'WHERE asvs.sample_id = ?)', sample_id)

    format_taxa(taxa)
  end

  def fetch_asv_tree_for_research_project(project_id)
    sql = <<~SQL
      ncbi_nodes.taxon_id IN (
        SELECT DISTINCT taxon_id FROM asvs
        WHERE asvs.research_project_id = ?
      )
    SQL
    taxa = fetch_asv_tree.where(sql, project_id)

    format_taxa(taxa)
  end

  private

  def format_taxon_id(taxon_id, domain)
    return if taxon_id.blank?

    if domain == 'Environmental samples'
      "es_#{taxon_id}"
    else
      taxon_id.to_i
    end
  end

  def fetch_asv_tree
    @fetch_asv_tree ||= begin
      base_asv_tree_taxa
    end
  end

  def base_asv_tree_taxa
    @base_asv_tree_taxa ||= begin
      NcbiNode
        .joins(:ncbi_division)
        .select('ncbi_divisions.name as domain')
        .select('ncbi_nodes.rank, ncbi_nodes.cal_division_id as domain_id')
        .select('ncbi_nodes.hierarchy_names, ncbi_nodes.hierarchy')
        .select('ncbi_nodes.common_names')
    end
  end

  def format_taxa(taxa)
    tree = taxa.map do |taxon|
      taxon_object = create_taxon_object(taxon)
      create_tree_objects(taxon_object, taxon.rank)
    end.flatten
    tree << { name: 'Life', id: 'Life', rank: nil, parent_id: nil }
    tree.uniq { |i| [i[:parent_id], i[:id]] }
  end

  def format_blank_rank(name, rank)
    "#{rank}_#{name}"
  end

  def format_blank_name(name, rank)
    prev_name = name.split(' for ').last
    "#{rank} for #{prev_name}"
  end
end
