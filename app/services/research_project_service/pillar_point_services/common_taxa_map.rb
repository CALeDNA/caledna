# frozen_string_literal: true

module ResearchProjectService
  module PillarPointServices
    module CommonTaxaMap
      def conn
        @conn ||= ActiveRecord::Base.connection
      end

      def common_taxa_map
        @common_taxa_map ||= begin
          sql = <<-SQL
          #{fields_sql('gbif_ct')},
          (SELECT pillar_point.ncbi_nodes.common_names
          FROM pillar_point.ncbi_nodes
          JOIN pillar_point.ncbi_names
            ON pillar_point.ncbi_nodes.taxon_id = pillar_point.ncbi_names.taxon_id
          WHERE lower(pillar_point.ncbi_names.name) =
            lower(gbif_ct.#{combine_taxon_rank_field})
          ) AS common_names
          FROM pillar_point.combine_taxa as gbif_ct
          JOIN external.gbif_occurrences
            ON external.gbif_occurrences.taxonkey = gbif_ct.source_taxon_id
          WHERE gbif_ct.source = 'gbif'
          AND gbif_ct.#{combine_taxon_rank_field} IS NOT NULL
          AND gbif_ct.#{combine_taxon_rank_field} IN (
            SELECT combine_taxa.#{combine_taxon_rank_field}
            FROM  pillar_point.combine_taxa
            WHERE source = 'ncbi' OR source = 'bold'
          )

          GROUP BY #{group_fields}
          ORDER BY #{sort_fields};
          SQL
          conn.exec_query(sql)
        end
      end

      # rubocop:disable Metrics/MethodLength
      def common_taxa_edna
        return [] if taxon.blank?
        return [] if rank.blank?

        sql = <<-SQL
          SELECT DISTINCT barcode, latitude, longitude, samples.id,
          samples.status_cd AS status
          FROM pillar_point.asvs as pp_asvs
          JOIN samples
            ON pp_asvs.sample_id = samples.id
          JOIN pillar_point.combine_taxa
            ON pp_asvs.taxon_id = pillar_point.combine_taxa.caledna_taxon_id
            AND pillar_point.combine_taxa.#{rank} = '#{taxon}'
            AND (source = 'ncbi' OR source = 'bold')
          WHERE pp_asvs.research_project_id = #{project.id};
        SQL

        conn.exec_query(sql)
      end
      # rubocop:enable Metrics/MethodLength

      # rubocop:disable Metrics/MethodLength
      def common_taxa_gbif
        return [] if taxon.blank?
        return [] if rank.blank?

        sql = <<-SQL
          SELECT DISTINCT external.gbif_occurrences.gbifid AS id,
            decimallongitude AS longitude,
            decimallatitude AS latitude, pillar_point.combine_taxa.kingdom,
            pillar_point.combine_taxa.species
          FROM external.gbif_occurrences
          JOIN research_project_sources
            ON research_project_sources.sourceable_id =
              external.gbif_occurrences.gbifid
            AND (research_project_sources.sourceable_type = 'GbifOccurrence')
            AND (research_project_sources.research_project_id = #{project.id})
            AND (metadata ->> 'location' != 'Montara SMR')
          JOIN pillar_point.combine_taxa
            ON external.gbif_occurrences.taxonkey =
              pillar_point.combine_taxa.source_taxon_id
            AND pillar_point.combine_taxa.#{rank} = '#{taxon}'
            AND (source = 'gbif');
        SQL

        conn.exec_query(sql)
      end
      # rubocop:enable Metrics/MethodLength
    end
  end
end
