# frozen_string_literal: true

namespace :cal_taxa do
  task update_missing_superkingdom_string: :environment do
    sql =  <<-SQL
    update cal_taxa
    set original_taxonomy_superkingdom =
      coalesce(hierarchy ->> 'superkingdom', '') ||
      ';' || original_taxonomy_phylum
    where cal_taxa.original_taxonomy_superkingdom is null;
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
    cal_taxa = CalTaxon.where(sql).where(normalized: false)

    cal_taxa.each do |cal_taxon|
      ncbi_taxa =
        find_taxa_by_hierarchy(cal_taxon.hierarchy, cal_taxon.taxon_rank)
      next unless ncbi_taxa.to_a.size == 1

      puts "#{cal_taxon.original_taxonomy_string} - #{ncbi_taxa.first.taxon_id}"
      cal_taxon.taxon_id = ncbi_taxa.first.taxon_id
      cal_taxon.normalized = true
      cal_taxon.save
    end
  end
end
