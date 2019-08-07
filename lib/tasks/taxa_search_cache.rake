# frozen_string_literal: true

namespace :taxa_search_cache do
  task cache: :environment do
    require_relative '../../app/services/custom_counter'
    include CustomCounter

    puts 'create cache...'

    sql = "rank = 'superkingdom' OR rank ='kingdom' OR rank='phylum'"
    NcbiNode.where(sql).where('asvs_count > 0').each do |node|
      ids = get_sample_ids(node.taxon_id)

      cache = TaxaSearchCache.where(taxon_id: node.taxon_id,
                                    canonical_name: node.canonical_name,
                                    rank: node.rank)
                             .first_or_create

      cache.update(
        asvs_count: node.asvs_count,
        sample_ids: ids
      )
    end
  end

  task cache_la_river: :environment do
    require_relative '../../app/services/custom_counter'
    include CustomCounter

    puts 'create cache...'

    sql = "rank = 'superkingdom' OR rank ='kingdom' OR rank='phylum'"
    NcbiNode.where(sql).where('asvs_count_la_river > 0').each do |node|
      ids = get_sample_ids_la_river(node.taxon_id)

      cache = TaxaSearchCache.where(taxon_id: node.taxon_id,
                                    canonical_name: node.canonical_name,
                                    rank: node.rank)
                             .first_or_create

      cache.update(
        asvs_count_la_river: node.asvs_count_la_river,
        sample_ids_la_river: ids
      )
    end
  end
end
