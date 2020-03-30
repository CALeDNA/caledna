# frozen_string_literal: true

# rubocop:disable Metrics/MethodLength
module ResearchProjectService
  module LaRiverServices
    module DetectionFrequency
      def detection_frequency
        {
          cal: biodiversity_bias_cal
        }
      end

      def biodiversity_bias_cal
        sql = <<~SQL
          SELECT count(*) AS count,
          ncbi_divisions.name AS division,
          ncbi_divisions.name as kingdom,
          ncbi_nodes.hierarchy_names ->> 'phylum' as phylum,
          ncbi_nodes.hierarchy_names ->> '#{taxon_rank}' as #{taxon_rank},
          'ncbi' AS source
          FROM ncbi_nodes
          JOIN asvs
            ON asvs.taxon_id = ncbi_nodes.taxon_id
          JOIN ncbi_divisions
            ON ncbi_nodes.cal_division_id = ncbi_divisions.id
          JOIN research_project_sources
            ON asvs.sample_id = research_project_sources.sourceable_id
          WHERE sourceable_type = 'Sample'
          AND research_project_sources.research_project_id = #{project.id}
          AND ncbi_nodes.hierarchy_names ->> '#{taxon_rank}' IS NOT NULL
          #{taxon_group_filters}
          GROUP BY
          ncbi_divisions.name,
          ncbi_nodes.hierarchy_names ->> 'phylum' ,
          ncbi_nodes.hierarchy_names ->> '#{taxon_rank}'
          ORDER BY count DESC;
        SQL

        conn.exec_query(sql)
      end

      def taxon_group_filters
        return if taxon_groups.blank?

        " AND ncbi_divisions.name in (#{selected_taxon_groups})"
      end
    end
  end
end
# rubocop:enable Metrics/MethodLength
