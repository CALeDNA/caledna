# frozen_string_literal: true

namespace :taxa_search_cache do
  task cache: :environment do
    require_relative '../../app/services/custom_counter'
    include CustomCounter

    puts 'destroy cache...'
    TaxaSearchCache.destroy_all

    puts 'create cache...'

    sql = "rank = 'superkingdom' OR rank ='kingdom' OR rank='phylum'"
    NcbiNode.where(sql).each do |node|
      ids = get_sample_ids(node.taxon_id)

      TaxaSearchCache.create(
        taxon_id: node.taxon_id,
        asvs_count: ids.count,
        sample_ids: ids.map { |id| id['id'] },
        canonical_name: node.canonical_name,
        rank: node.rank
      )
    end
  end
end
