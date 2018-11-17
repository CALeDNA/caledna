# frozen_string_literal: true

# rubocop:disable Metrics/MethodLength
module ResearchProjectService
  module PillarPointServices
    module CommonTaxaMap
      def common_taxa_map
        @common_taxa_map ||= begin
          rank = taxon_rank == 'class' ? 'classname' : taxon_rank

          sql = <<-SQL
          SELECT
          distinct gbif_taxa.taxonkey as gbif_id, external_resources.ncbi_id,
          gbif_taxa.#{rank} as gbif_name,
          ncbi_nodes.canonical_name as ncbi_name
          SQL
          sql += gbif_select_sql
          sql += gbif_taxa_with_edna_sql
          sql += 'ORDER BY ncbi_name'

          conn.exec_query(sql)
        end
      end
    end
  end
end
# rubocop:enable Metrics/MethodLength
