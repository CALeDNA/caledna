# frozen_string_literal: true

module ResearchProjectService
  module PillarPointServices
    module GbifEdnaComparison
      def gbif_taxa
        @gbif_taxa ||= begin
          sql = gbif_fields_sql
          sql += gbif_select_sql
          sql += gbif_group_sql
          conn.exec_query(sql)
        end
      end

      def gbif_taxa_with_edna
        @gbif_taxa_with_edna ||= begin
          sql = gbif_fields_sql
          sql += gbif_select_sql
          sql += gbif_taxa_with_edna_sql
          sql += gbif_group_sql

          conn.exec_query(sql)
        end
      end

      private

      def taxon_rank_value
        conn.quote(taxon_rank)
      end

      def taxon_rank_field
        taxon_rank == 'class' ? 'classname' : conn.quote_column_name(taxon_rank)
      end

      def gbif_fields_sql
        <<-SQL
        SELECT count(*),
        gbif_taxa.taxonkey as gbif_id, external_resources.ncbi_id,
        asvs."taxonID" as asvs_taxon_id,
        gbif_taxa.kingdom, gbif_taxa.phylum, gbif_taxa.classname,
        gbif_taxa.order, gbif_taxa.family, gbif_taxa.genus, gbif_taxa.species,
        ncbi_nodes.hierarchy_names, ncbi_nodes.rank as ncbi_rank
        SQL
      end

      def gbif_select_sql
        <<-SQL
        FROM research_project_sources
        JOIN external.gbif_occurrences
          ON external.gbif_occurrences.gbifid =
          research_project_sources.sourceable_id
          AND research_project_id = #{project.id}
          AND sourceable_type = 'GbifOccurrence'
          AND external.gbif_occurrences.#{taxon_rank_field} IS NOT NULL
          AND metadata ->> 'location' != 'Montara SMR'
        JOIN external.gbif_occ_taxa AS gbif_taxa
          ON gbif_taxa.#{taxon_rank_field} =
          external.gbif_occurrences.#{taxon_rank_field}
          AND gbif_taxa.taxonrank = #{taxon_rank_value}
        LEFT JOIN external_resources
          ON external_resources.gbif_id = gbif_taxa.taxonkey
          AND external_resources.ncbi_id IS NOT NULL
          AND source != 'wikidata'
        LEFT JOIN ncbi_nodes
          ON ncbi_nodes.taxon_id = external_resources.ncbi_id
        LEFT JOIN asvs
          ON asvs.extraction_id = research_project_sources.sourceable_id
          AND research_project_id = #{project.id}
          AND sourceable_type = 'Extraction'
        SQL
      end

      def gbif_group_sql
        <<-SQL
        GROUP BY gbif_taxa.taxonkey, external_resources.ncbi_id,
        asvs."taxonID",
        gbif_taxa.kingdom, gbif_taxa.phylum, gbif_taxa.classname,
        gbif_taxa.order, gbif_taxa.family, gbif_taxa.genus, gbif_taxa.species,
        ncbi_nodes.hierarchy_names, ncbi_nodes.rank
        ORDER BY #{sort_fields};
        SQL
      end

      def gbif_taxa_with_edna_sql
        <<-SQL
        WHERE ncbi_nodes.taxon_id IN (
          SELECT distinct(unnest(ids))::TEXT::NUMERIC
          FROM asvs
          JOIN extractions
            ON asvs.extraction_id = extractions.id
          JOIN research_project_sources
            ON research_project_sources.sourceable_id = asvs.extraction_id
            AND research_project_id = #{project.id}
            AND sourceable_type = 'Extraction'
          JOIN ncbi_nodes
            ON ncbi_nodes.taxon_id = asvs."taxonID"
        )
        SQL
      end

      def sort_fields
        if sort_by == 'count'
          'count(*) DESC'
        else
          'gbif_taxa.kingdom, gbif_taxa.phylum, gbif_taxa.classname, ' \
          'gbif_taxa.order, gbif_taxa.family, gbif_taxa.genus, ' \
          'gbif_taxa.species'
        end
      end
    end
  end
end
