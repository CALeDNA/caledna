# frozen_string_literal: true

# rubocop:disable Metrics/MethodLength, Metrics/CyclomaticComplexity
module ResearchProjectService
  module PillarPointServices
    module GbifEdnaComparison
      def gbif_taxa
        @gbif_taxa ||= begin
          sql = <<~SQL
            #{fields_sql('gbif_ct')},
            #{match_sql('edna_ct')},
            #{aggregate_sql}
            #{join_sql}
            WHERE gbif_ct.source = 'gbif'
            AND gbif_ct.#{combine_taxon_rank_field} IS NOT NULL
            GROUP BY #{group_fields}
            ORDER BY #{sort_fields};
          SQL
          conn.exec_query(sql)
        end
      end

      private

      def fields_sql(table = 'combine_taxa')
        fields = [
          "#{table}.phylum",
          "#{table}.class_name",
          "#{table}.order",
          "#{table}.family",
          "#{table}.genus",
          "#{table}.species"
        ]
        sql = "SELECT #{table}.superkingdom, #{table}.kingdom, "
        sql += case taxon_rank
               when 'phylum' then fields[0]
               when 'class' then fields[0..1].join(', ')
               when 'order' then fields[0..2].join(', ')
               when 'family' then fields[0..3].join(', ')
               when 'genus' then fields[0..4].join(', ')
               when 'species' then fields[0..5].join(', ')
               end
        sql
      end

      def ct_taxa_sql(table)
        fields = [
          "coalesce(#{table}.source_phylum, '--')",
          "coalesce(#{table}.source_class_name, '--')",
          "coalesce(#{table}.source_order, '--')",
          "coalesce(#{table}.source_family, '--')",
          "coalesce(#{table}.source_genus, '--')",
          "coalesce(#{table}.source_species, '--')"
        ]
        sql = "coalesce(#{table}.source_superkingdom, '--') || '|' ||"
        sql += "coalesce(#{table}.source_kingdom, '--') || '|' ||"
        sql += case taxon_rank
               when 'phylum' then fields[0]
               when 'class' then fields[0..1].join("|| '|' ||")
               when 'order' then fields[0..2].join("|| '|' ||")
               when 'family' then fields[0..3].join("|| '|' ||")
               when 'genus' then fields[0..4].join("|| '|' ||")
               when 'species' then fields[0..5].join("|| '|' ||")
               end
        sql
      end

      # rubocop:disable Metrics/AbcSize
      def ncbi_taxa_sql
        fields = [
          "coalesce(ncbi_nodes.hierarchy_names ->> 'phylum', '--')",
          "coalesce(ncbi_nodes.hierarchy_names ->> 'class', '--')",
          "coalesce(ncbi_nodes.hierarchy_names ->> 'order', '--')",
          "coalesce(ncbi_nodes.hierarchy_names ->> 'family', '--')",
          "coalesce(ncbi_nodes.hierarchy_names ->> 'genus', '--')",
          "coalesce(ncbi_nodes.hierarchy_names ->> 'species', '--')"
        ]
        sql = "coalesce(ncbi_nodes.hierarchy_names ->> 'superkingdom', '--') "
        sql += "|| '|' ||"
        sql += "coalesce(ncbi_nodes.hierarchy_names ->> 'kingdom', '--') "
        sql += "|| '|' ||"
        sql += case taxon_rank
               when 'phylum' then fields[0]
               when 'class' then fields[0..1].join("|| '|' ||")
               when 'order' then fields[0..2].join("|| '|' ||")
               when 'family' then fields[0..3].join("|| '|' ||")
               when 'genus' then fields[0..4].join("|| '|' ||")
               when 'species' then fields[0..5].join("|| '|' ||")
               end
        sql
      end
      # rubocop:enable Metrics/AbcSize

      def match_sql(table)
        ncbi_match_sql =
          if %w[phylum class order].include?(taxon_rank)
            'true'
          else
            '(SELECT count(*) ' \
            'FROM ncbi_names ' \
            'WHERE lower(ncbi_names.name) = ' \
            "lower(gbif_ct.#{combine_taxon_rank_field})) != 0 "
          end

        <<~SQL
          #{ncbi_match_sql} AS ncbi_match,
          #{table}.#{combine_taxon_rank_field} IS NOT NULL AS edna_match
        SQL
      end

      def aggregate_sql
        <<~SQL
          COUNT(distinct (gbifid)),

          ARRAY_AGG(DISTINCT(
            g_taxa.taxonkey || '|' || #{ct_taxa_sql('gbif_ct')}
          )) AS gbif_taxa,


          (SELECT ARRAY_AGG(ncbi_nodes.taxon_id || '|' ||  #{ncbi_taxa_sql})
          FROM ncbi_nodes
          JOIN ncbi_names
            ON ncbi_nodes.taxon_id = ncbi_names.taxon_id
          WHERE lower(ncbi_names.name) =
            lower(gbif_ct.#{combine_taxon_rank_field})
          ) AS ncbi_taxa
        SQL
      end

      def join_sql
        <<~SQL
          FROM combine_taxa as gbif_ct
          JOIN external.gbif_occurrences
            ON external.gbif_occurrences.taxonkey = gbif_ct.source_taxon_id
            AND gbif_ct.source = 'gbif'
          JOIN  research_project_sources
            ON external.gbif_occurrences.gbifid = research_project_sources.sourceable_id
            AND research_project_id = #{project.id}
            AND sourceable_type = 'GbifOccurrence'
            AND metadata ->> 'location' != 'Montara SMR'
          LEFT JOIN combine_taxa AS edna_ct
            ON edna_ct.#{combine_taxon_rank_field} = gbif_ct.#{combine_taxon_rank_field}
            AND (edna_ct.source = 'ncbi' OR edna_ct.source = 'bold')
          LEFT JOIN external.gbif_occ_taxa as g_taxa
            ON gbif_ct.source_#{combine_taxon_rank_field} = g_taxa.#{gbif_taxon_rank_field}
            AND g_taxa.taxonrank = '#{taxon_rank}'
        SQL
      end

      # rubocop:disable Metrics/AbcSize
      def group_fields
        fields = %w[
          gbif_ct.phylum
          gbif_ct.class_name
          gbif_ct.order
          gbif_ct.family
          gbif_ct.genus
          gbif_ct.species
        ]
        other_fields = ["edna_ct.#{combine_taxon_rank_field}"]
        sql = 'gbif_ct.superkingdom, gbif_ct.kingdom, '
        sql += case taxon_rank
               when 'phylum' then (fields[0..0] + other_fields).join(', ')
               when 'class' then (fields[0..1] + other_fields).join(', ')
               when 'order' then (fields[0..2] + other_fields).join(', ')
               when 'family' then (fields[0..3] + other_fields).join(', ')
               when 'genus' then (fields[0..4] + other_fields).join(', ')
               when 'species' then (fields[0..5] + other_fields).join(', ')
               end
        sql
      end
      # rubocop:enable Metrics/AbcSize

      def sort_fields
        if sort_by == 'count'
          'count DESC'
        else
          group_fields
        end
      end
    end
  end
end
# rubocop:enable Metrics/MethodLength, Metrics/CyclomaticComplexity
