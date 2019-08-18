# frozen_string_literal: true

module VegaFormatter
  # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity
  # rubocop:disable Metrics/PerceivedComplexity, Metrics/MethodLength
  def create_taxon_object(taxon)
    rank = taxon.rank
    su = taxon.hierarchy_names['superkingdom']
    k = taxon.hierarchy_names['kingdom']
    p = taxon.hierarchy_names['phylum']
    c = taxon.hierarchy_names['class']
    o = taxon.hierarchy_names['order']
    f = taxon.hierarchy_names['family']
    g = taxon.hierarchy_names['genus']
    sp = taxon.hierarchy_names['species']

    su_id = taxon.hierarchy['superkingdom'].try(:to_i)
    k_id = taxon.hierarchy['kingdom'].try(:to_i)
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
      results[:genus] = g
      results[:genus_id] = g_id || format_blank_rank(results[:species_id], 'g')
    end
    if %w[species genus family].include?(rank)
      results[:family] = f
      results[:family_id] = f_id || format_blank_rank(results[:genus_id], 'f')
    end
    if %w[species genus family order].include?(rank)
      results[:order] = o
      results[:order_id] = o_id || format_blank_rank(results[:family_id], 'o')
    end
    if %w[species genus family order class].include?(rank)
      results[:class] = c
      results[:class_id] = c_id || format_blank_rank(results[:order_id], 'c')
    end
    if %w[species genus family order class phylum].include?(rank)
      results[:phylum] = p
      results[:phylum_id] = p_id || format_blank_rank(results[:class_id], 'p')
    end
    if %w[species genus family order class phylum kingdom].include?(rank)
      results[:kingdom] = k
      results[:kingdom_id] = k_id || format_blank_rank(results[:phylum_id], 'k')
    end
    results[:superkingdom] = su
    results[:superkingdom_id] =
      su_id || format_blank_rank(results[:kingdom_id], 'su')

    results.reject { |_k, v| v.blank? }
  end
  # rubocop:enable Metrics/AbcSize, Metrics/CyclomaticComplexity
  # rubocop:enable Metrics/PerceivedComplexity, Metrics/MethodLength

  def format_blank_rank(name, rank)
    "#{rank}_#{name}"
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
      objects << create_tree_object(taxon_object, :kingdom, :superkingdom_id,
                                    :kingdom_id)
    end
    objects << { name: taxon_object[:superkingdom],
                 parent: 'root',
                 id: taxon_object[:superkingdom_id] }
    objects
  end
  # rubocop:enable Metrics/AbcSize, Metrics/CyclomaticComplexity
  # rubocop:enable Metrics/PerceivedComplexity, Metrics/MethodLength
end
