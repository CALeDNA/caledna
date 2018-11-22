# frozen_string_literal: true

module ResearchProjectService
  module PillarPointServices
    module CommonTaxaMap
      def common_taxa_map
        @common_taxa_map ||= begin
          sql = <<-SQL
            #{fields_sql},
            #{aggregate_sql}
            #{join_sql}
            WHERE combine_taxa.source = 'gbif'
            AND ncbi_nodes.taxon_id in (
              #{edna_match_sql}
            )
            GROUP BY #{group_fields}
            ORDER BY #{sort_fields};
          SQL
          conn.exec_query(sql)
        end
      end
    end
  end
end
