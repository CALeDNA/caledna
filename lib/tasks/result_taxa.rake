# frozen_string_literal: true

namespace :result_taxa do
  task update_missing_superkingdom_string: :environment do
    sql =  <<-SQL
    update result_taxa
    set original_taxonomy_superkingdom =
      coalesce(hierarchy ->> 'superkingdom', '') ||
      ';' || original_taxonomy_phylum
    where result_taxa.original_taxonomy_superkingdom is null;
    SQL

    ActiveRecord::Base.connection.execute(sql)
  end

  # skip checking phylum hierarchy when looking for taxa that match ceratin
  # taxonomy strings
  task normalize_strings_without_phylum: :environment do
    # rubocop:disable Metrics/MethodLength
    def find_taxa_by_hierarchy(hierarchy, target_rank)
      clauses = []
      ranks = %w[superkingdom class order family genus species]
      ranks.each do |rank|
        next if hierarchy[rank].blank?
        clauses << '"' + rank + '": "' +
                   hierarchy[rank].gsub("'", "''") + '"'
      end
      sql = "rank = '#{target_rank}' AND  hierarchy_names @> '{"
      sql += clauses.join(', ')
      sql += "}'"

      NcbiNode.where(sql)
    end
    # rubocop:enable Metrics/MethodLength

    sql = "hierarchy ->> 'class' = 'Oomycetes' OR " \
          " hierarchy ->> 'class' = 'Florideophyceae'"
    result_taxa = ResultTaxon.where(sql).where(normalized: false)

    result_taxa.each do |result_taxon|
      ncbi_taxa =
        find_taxa_by_hierarchy(result_taxon.hierarchy, result_taxon.taxon_rank)
      next unless ncbi_taxa.to_a.size == 1

      puts "#{result_taxon.original_taxonomy_string} - " \
        "#{ncbi_taxa.first.taxon_id}"
      result_taxon.taxon_id = ncbi_taxa.first.taxon_id
      result_taxon.normalized = true
      result_taxon.save
    end
  end
end
