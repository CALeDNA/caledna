# frozen_string_literal: true

# rubocop:disable Metrics/MethodLength, Metrics/CyclomaticComplexity
module ResearchProjectService
  module PillarPointServices
    module GbifEdnaComparison
      def gbif_taxa
        @gbif_taxa ||= begin
          sql = <<-SQL
            #{fields_sql},
            #{match_sql},
            #{aggregate_sql}
            #{join_sql}
            WHERE combine_taxa.source = 'gbif'
            GROUP BY #{group_fields}
            ORDER BY #{sort_fields};
          SQL
          conn.exec_query(sql)
        end
      end

      private

      def fields_sql
        fields = %w[
          combine_taxa.phylum
          combine_taxa.class_name
          combine_taxa.order
          combine_taxa.family
          combine_taxa.genus
          combine_taxa.species
        ]
        sql = 'SELECT combine_taxa.superkingdom, '
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

      def gbif_taxa_sql
        fields = [
          "coalesce(external.gbif_occ_taxa.phylum, '--')",
          "coalesce(external.gbif_occ_taxa.classname, '--')",
          "coalesce(external.gbif_occ_taxa.order, '--')",
          "coalesce(external.gbif_occ_taxa.family, '--')",
          "coalesce(external.gbif_occ_taxa.genus, '--')",
          "coalesce(external.gbif_occ_taxa.species, '--')"
        ]
        sql = "external.gbif_occ_taxa.kingdom || '|' ||"
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

      def ncbi_taxa_sql
        fields = [
          "coalesce(ncbi_nodes.hierarchy_names ->> 'phylum', '--')",
          "coalesce(ncbi_nodes.hierarchy_names ->> 'class', '--')",
          "coalesce(ncbi_nodes.hierarchy_names ->> 'order', '--')",
          "coalesce(ncbi_nodes.hierarchy_names ->> 'family', '--')",
          "coalesce(ncbi_nodes.hierarchy_names ->> 'genus', '--')",
          "coalesce(ncbi_nodes.hierarchy_names ->> 'species', '--')"
        ]
        sql = "coalesce(ncbi_nodes.hierarchy_names ->> 'superkingdom', '--') " \
          "|| '|' ||"
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

      def edna_match_sql
        <<-SQL
          SELECT DISTINCT(unnest(ids))::TEXT::INTEGER
            FROM asvs
            JOIN extractions
              ON asvs.extraction_id = extractions.id
            JOIN research_project_sources
              ON research_project_sources.sourceable_id = asvs.extraction_id
              AND research_project_id = 4
              AND sourceable_type = 'Extraction'
            JOIN ncbi_nodes
              ON ncbi_nodes.taxon_id = asvs."taxonID"
        SQL
      end

      def match_sql
        <<-SQL
          ARRAY_AGG(DISTINCT(
            ncbi_nodes.ncbi_id
          )) != ARRAY[NULL]::integer[] AS ncbi_match,
          ARRAY_AGG(DISTINCT(
            ncbi_nodes.ncbi_id
          )) && (
            ARRAY(
            #{edna_match_sql}
          )) AS edna_match
        SQL
      end

      def aggregate_sql
        <<-SQL
          COUNT(*),
          ARRAY_AGG(DISTINCT(
            external.gbif_occ_taxa.taxonkey || '|' ||
            #{gbif_taxa_sql}
          )) AS  gbif_taxa,
          ARRAY_AGG(DISTINCT(
            ncbi_nodes.ncbi_id || '|' ||
            #{ncbi_taxa_sql}
          )) AS  ncbi_taxa
        SQL
      end

      def join_sql
        <<-SQL
          FROM combine_taxa
          JOIN external.gbif_occurrences
            ON external.gbif_occurrences.taxonkey = combine_taxa.taxon_id
            AND combine_taxa.source = 'gbif'
          JOIN  research_project_sources
            ON external.gbif_occurrences.gbifid = research_project_sources.sourceable_id
            AND research_project_id = 4
            AND sourceable_type = 'GbifOccurrence'
            AND external.gbif_occurrences.#{gbif_taxon_rank_field} IS NOT NULL
            AND metadata ->> 'location' != 'Montara SMR'
          JOIN external.gbif_occ_taxa
            ON external.gbif_occ_taxa.#{gbif_taxon_rank_field} =
            external.gbif_occurrences.#{gbif_taxon_rank_field}
            AND external.gbif_occ_taxa.taxonrank = '#{taxon_rank}'
          LEFT JOIN external_resources
            ON external_resources.gbif_id = external.gbif_occ_taxa.taxonkey
            AND external_resources.ncbi_id IS NOT NULL
            AND external_resources.source != 'wikidata'
          LEFT JOIN ncbi_nodes
            ON ncbi_nodes.taxon_id = external_resources.ncbi_id
        SQL
      end

      def group_fields
        fields = %w[
          combine_taxa.phylum
          combine_taxa.class_name
          combine_taxa.order
          combine_taxa.family
          combine_taxa.genus
          combine_taxa.species
        ]
        sql = 'combine_taxa.superkingdom, '
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

      def sort_fields
        if sort_by == 'count'
          'count(*) DESC'
        else
          group_fields
        end
      end
    end
  end
end
# rubocop:enable Metrics/MethodLength, Metrics/CyclomaticComplexity
