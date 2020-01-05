# frozen_string_literal: true

# rubocop:disable Metrics/MethodLength, Metrics/AbcSize
module ResearchProjectService
  module PillarPointServices
    module BioticInteractions
      def globi_target_taxon
        return unless globi_taxon

        taxon =
          NcbiNode
          .where("lower(canonical_name) = #{conn.quote(globi_taxon.downcase)}")
          .first

        if taxon.present?
          path = [
            taxon.hierarchy_names['kingdom'],
            taxon.hierarchy_names['phylum'],
            taxon.hierarchy_names['class'],
            taxon.hierarchy_names['order'],
            taxon.hierarchy_names['family'],
            taxon.hierarchy_names['genus'],
            taxon.hierarchy_names['species']
          ].join(';')
          rank = taxon.rank
        else
          taxon =
            GbifOccTaxa
            .where("species = #{conn.quote(globi_taxon)}")
            .first
          if taxon.present?
            path = [taxon.kingdom, taxon.phylum, taxon.classname, taxon.order,
                    taxon.family, taxon.genus, taxon.species].join(';')
            rank = taxon.taxonrank
          end
        end

        sql = <<-SQL
        select #{conn.quote(globi_taxon)} as taxon_name,
        #{conn.quote(path)} as taxon_path,
        #{conn.quote(rank)} as taxon_rank,
        #{conn.quote(globi_taxon)} IN(
          SELECT unnest(array[kingdom, phylum, classname, "order", family,
          genus, species])
          FROM research_project_sources
          JOIN external.gbif_occurrences
          ON external.gbif_occurrences.gbifid =
            research_project_sources.sourceable_id
          WHERE research_project_id = #{project.id}
          AND sourceable_type = 'GbifOccurrence'
          AND metadata ->> 'location' != 'Montara SMR'
        ) as gbif_match,
        #{conn.quote(globi_taxon)} IN(
          SELECT  unnest(string_to_array(full_taxonomy_string, ';'))
          FROM research_project_sources
          JOIN asvs
          ON asvs.sample_id = research_project_sources.sourceable_id
          JOIN ncbi_nodes
          ON ncbi_nodes.taxon_id = asvs."taxonID"
          WHERE research_project_id = #{project.id}
          AND sourceable_type = 'Sample'
        ) as edna_match;
        SQL

        results = conn.exec_query(sql)
        results.to_hash.first
      end

      def globi_interactions
        return [] unless globi_taxon

        sql = <<-SQL
        #{globi_source_sql}
        UNION
        #{globi_target_sql}
        ORDER BY edna_match DESC, gbif_match DESC, interaction_type
        SQL

        conn.exec_query(sql)
      end

      def globi_index
        return [] if globi_taxon

        sql = <<-SQL
        #{globi_index_sql}
        LIMIT #{limit} OFFSET #{offset}
        SQL

        raw_records = conn.exec_query(sql)
        records = raw_records.map { |r| OpenStruct.new(r) }
        add_pagination_methods(records)
        records
      end

      private

      def globi_target_sql
        <<-SQL
          SELECT DISTINCT
          "sourceTaxonName" AS source_taxon_name,
          "sourceTaxonIds" AS source_taxon_ids,
          "sourceTaxonPathNames" AS source_taxon_path,
          "sourceTaxonRank" AS source_taxon_rank,
          "interactionTypeName" AS interaction_type,
          "targetTaxonName" AS target_taxon_name,
          "targetTaxonIds" AS target_taxon_ids,
          "targetTaxonPathNames" AS target_taxon_path,
          "targetTaxonRank" AS target_taxon_rank,
          'false' as is_source,
          ("targetTaxonName" IN
          (SELECT unnest(string_to_array(full_taxonomy_string, ';'))
          FROM research_project_sources
          JOIN asvs
          ON asvs.sample_id = research_project_sources.sourceable_id
          JOIN ncbi_nodes
          ON ncbi_nodes.taxon_id = asvs."taxonID"
          WHERE research_project_id = #{project.id}
          AND sourceable_type = 'Sample'
          INTERSECT
          SELECT ("targetTaxonName")
          FROM external.globi_interactions
          WHERE "sourceTaxonName" = #{conn.quote(globi_taxon)} )
        ) AS edna_match,
        ("targetTaxonName" in
          (SELECT unnest(ARRAY[kingdom, phylum, classname, "order", family,
          genus, species])
          FROM research_project_sources
          JOIN external.gbif_occurrences
          ON external.gbif_occurrences.gbifid =
            research_project_sources.sourceable_id
          WHERE research_project_id = #{project.id}
          AND sourceable_type = 'GbifOccurrence'
          AND metadata ->> 'location' != 'Montara SMR'
          INTERSECT
          SELECT "targetTaxonName"
          FROM external.globi_interactions
          WHERE "sourceTaxonName" = #{conn.quote(globi_taxon)} )
        ) as gbif_match
          FROM external.globi_interactions
          LEFT JOIN external.globi_requests
          ON external.globi_requests.taxon_name =
            external.globi_interactions."sourceTaxonName"
          WHERE "targetTaxonName" != 'Detritus'
          AND "targetTaxonName" != 'Detritus complex'
          AND "targetTaxonId" != 'no:match'
          AND "sourceTaxonName" = #{conn.quote(globi_taxon)}
          AND globi_requests.taxon_id[1]::text =
            ANY(string_to_array("sourceTaxonIds", ' | '))
        SQL
      end

      def globi_source_sql
        <<-SQL
        SELECT DISTINCT
        "sourceTaxonName" AS source_taxon_name,
        "sourceTaxonIds" AS source_taxon_ids,
        "sourceTaxonPathNames" AS source_taxon_path,
        "sourceTaxonRank" AS source_taxon_rank,
        "interactionTypeName" AS interaction_type,
        "targetTaxonName" AS target_taxon_name,
        "targetTaxonIds" AS target_taxon_ids,
        "targetTaxonPathNames" AS target_taxon_path,
        "targetTaxonRank" AS target_taxon_rank,
        'true' as is_source,
        ("sourceTaxonName" IN
          (SELECT unnest(string_to_array(full_taxonomy_string, ';'))
          FROM research_project_sources
          JOIN asvs
          ON asvs.sample_id = research_project_sources.sourceable_id
          JOIN ncbi_nodes
          ON ncbi_nodes.taxon_id = asvs."taxonID"
          WHERE research_project_id = #{project.id}
          AND sourceable_type = 'Sample'
          INTERSECT
          SELECT ("sourceTaxonName")
          FROM external.globi_interactions
          WHERE "targetTaxonName" = #{conn.quote(globi_taxon)} )
        ) AS edna_match,
        ("sourceTaxonName" in
          (SELECT unnest(ARRAY[kingdom, phylum, classname, "order", family,
          genus, species])
          FROM research_project_sources
          JOIN external.gbif_occurrences
          ON external.gbif_occurrences.gbifid =
            research_project_sources.sourceable_id
          WHERE research_project_id = #{project.id}
          AND sourceable_type = 'GbifOccurrence'
          AND metadata ->> 'location' != 'Montara SMR'
          INTERSECT
          SELECT "sourceTaxonName"
          FROM external.globi_interactions
          WHERE "targetTaxonName" = #{conn.quote(globi_taxon)} )
        ) as gbif_match
        FROM external.globi_interactions
        LEFT JOIN external.globi_requests
        ON external.globi_requests.taxon_name =
          external.globi_interactions."targetTaxonName"
        WHERE "sourceTaxonName" != 'Detritus'
        AND "sourceTaxonName" != 'Detritus complex'
        AND "sourceTaxonId" != 'no:match'
        AND "targetTaxonName" = #{conn.quote(globi_taxon)}
        and globi_requests.taxon_id[1]::text =
        ANY(string_to_array("targetTaxonIds", ' | '))
        SQL
      end

      def globi_index_sql
        <<-SQL
        SELECT research_project_sources.metadata ->> 'image' AS image,
          research_project_sources.metadata ->> 'inat_at_pillar_point_count' AS count,
          taxon_name, gbif_id,
          inaturalist_id, external_resources.ncbi_id
        FROM external.globi_requests
        JOIN research_project_sources
        ON research_project_sources.sourceable_id = external.globi_requests.id
        LEFT JOIN external_resources
        ON  external_resources.inaturalist_id =
          (research_project_sources.metadata ->> 'inat_id')::integer
        AND external_resources.source != 'wikidata'
        WHERE research_project_id = #{project.id}
        AND sourceable_type = 'GlobiRequest'
        ORDER BY  (research_project_sources.metadata ->>
          'inat_at_pillar_point_count')::integer desc
        SQL
      end
    end
  end
end
# rubocop:enable Metrics/MethodLength, Metrics/AbcSize
