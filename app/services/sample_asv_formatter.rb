# frozen_string_literal: true

module SampleAsvFormatter
  # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity
  # rubocop:disable Metrics/PerceivedComplexity, Metrics/MethodLength
  def create_taxon_object(taxon)
    rank = taxon.rank
    k = taxon.ncbi_division.name
    p = taxon.hierarchy_names['phylum']
    c = taxon.hierarchy_names['class']
    o = taxon.hierarchy_names['order']
    f = taxon.hierarchy_names['family']
    g = taxon.hierarchy_names['genus']
    sp = taxon.hierarchy_names['species']

    k_id = taxon.cal_division_id.try(:to_i)
    p_id = taxon.hierarchy['phylum'].try(:to_i)
    c_id = taxon.hierarchy['class'].try(:to_i)
    o_id = taxon.hierarchy['order'].try(:to_i)
    f_id = taxon.hierarchy['family'].try(:to_i)
    g_id = taxon.hierarchy['genus'].try(:to_i)
    sp_id = taxon.hierarchy['species'].try(:to_i)

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
      results[:kingdom] = k || format_blank_name(results[:phylum], 'kingdom')
      results[:kingdom_id] = k_id || format_blank_rank(results[:phylum_id], 'k')
    end

    results.reject { |_k, v| v.blank? }
  end
  # rubocop:enable Metrics/AbcSize, Metrics/CyclomaticComplexity
  # rubocop:enable Metrics/PerceivedComplexity, Metrics/MethodLength

  def format_blank_rank(name, rank)
    "#{rank}_#{name}"
  end

  def format_blank_name(name, rank)
    prev_name = name.split(' for ').last
    "#{rank} for #{prev_name}"
  end

  def create_tree_object(taxon_object, name, parent, id)
    {
      name: taxon_object[name],
      parent: taxon_object[parent],
      id: taxon_object[id]
    }
  end

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
                   parent: 'Life',
                   id: taxon_object[:kingdom_id] }
    end
    objects
  end
  # rubocop:enable Metrics/AbcSize, Metrics/CyclomaticComplexity
  # rubocop:enable Metrics/PerceivedComplexity, Metrics/MethodLength
end
