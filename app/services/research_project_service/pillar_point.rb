# frozen_string_literal: true

# rubocop:disable Metrics/MethodLength
module ResearchProjectService
  class PillarPoint
    attr_reader :project, :taxon_rank, :sort_by, :params, :globi_id

    def initialize(project, params)
      @project = project
      @taxon_rank = params[:taxon_rank] || 'phylum'
      @sort_by = params[:sort]
      @params = params
      @globi_id = params[:interaction_id] || GlobiRequest.first.try(:id)
    end

    def conn
      @conn ||= ActiveRecord::Base.connection
    end

    def division_counts
      {
        cal: convert_counts(cal_division_stats),
        gbif: convert_counts(gbif_division_stats)
      }
    end

    def division_counts_unique
      {
        cal: convert_counts(cal_division_unique_stats),
        gbif: convert_counts(gbif_division_unique_stats)
      }
    end

    def gbif_breakdown
      {
        all: convert_counts(gbif_division_unique_stats),
        inat_only: convert_counts(inat_division_unique_stats),
        exclude_inat: convert_counts(exclude_inat_division_unique_stats)
      }
    end

    def stats
      { gbif_stats: gbif_stats, cal_stats: cal_stats }
    end

    def convert_counts(results)
      counts = {}
      results.to_a.map do |result|
        counts[result['category']] = result['count']
      end
      counts
    end

    def gbif_division_stats
      sql = <<-SQL
        SELECT  kingdom as category, count(kingdom)
        FROM external.gbif_occurrences
        JOIN research_project_sources
        ON research_project_sources.sourceable_id =
          external.gbif_occurrences.gbifid
        WHERE (research_project_sources.sourceable_type = 'GbifOccurrence')
      SQL

      sql += 'AND (research_project_sources.research_project_id = ' \
        "#{conn.quote(project.id)}) "

      sql += <<-SQL
        AND (metadata ->> 'location' != 'Montara SMR')
        GROUP BY kingdom
      SQL

      conn.exec_query(sql)
    end

    def gbif_unique_sql
      <<-SQL
      SELECT kingdom as category, count(taxonkey) FROM (
        SELECT DISTINCT(taxonkey), kingdom
        FROM external.gbif_occurrences
        JOIN research_project_sources
        ON research_project_sources.sourceable_id =
          external.gbif_occurrences.gbifid
        WHERE (research_project_sources.sourceable_type = 'GbifOccurrence')
      SQL
    end

    def gbif_division_unique_stats
      sql = gbif_unique_sql
      sql += 'AND (research_project_sources.research_project_id =  ' \
        "#{conn.quote(project.id)}) "

      sql += <<-SQL
          AND (metadata ->> 'location' != 'Montara SMR')
          ORDER BY kingdom
        ) AS foo
        GROUP BY kingdom;
      SQL

      conn.exec_query(sql)
    end

    def inat_division_unique_stats
      sql = gbif_unique_sql
      sql += 'AND (research_project_sources.research_project_id =  ' \
        "#{conn.quote(project.id)}) "

      sql += <<-SQL
          AND (metadata ->> 'location' != 'Montara SMR')
          AND external.gbif_occurrences.datasetkey = '50c9509d-22c7-4a22-a47d-8c48425ef4a7'
          ORDER BY kingdom
        ) AS foo
        GROUP BY kingdom;
      SQL
      conn.exec_query(sql)
    end

    def exclude_inat_division_unique_stats
      sql = gbif_unique_sql
      sql += 'AND (research_project_sources.research_project_id =  ' \
        "#{conn.quote(project.id)}) "

      sql += <<-SQL
          AND (metadata ->> 'location' != 'Montara SMR')
          AND external.gbif_occurrences.datasetkey != '50c9509d-22c7-4a22-a47d-8c48425ef4a7'
          ORDER BY kingdom
        ) AS foo
        GROUP BY kingdom;
      SQL
      conn.exec_query(sql)
    end

    def cal_division_stats
      sql = <<-SQL
        SELECT "name" AS category, COUNT(name) AS count
        FROM "asvs"
        INNER JOIN "ncbi_nodes"
        ON "ncbi_nodes"."taxon_id" = "asvs"."taxonID"
        INNER JOIN "ncbi_divisions"
        ON "ncbi_divisions"."id" = "ncbi_nodes"."cal_division_id"
        JOIN research_project_sources
        ON sourceable_id = extraction_id
        WHERE (research_project_sources.sourceable_type = 'Extraction')
      SQL

      sql += 'AND (research_project_sources.research_project_id = ' \
        "#{conn.quote(project.id)})"

      sql += <<-SQL
        GROUP BY name
        ORDER BY name;
      SQL

      conn.exec_query(sql)
    end

    def cal_division_unique_stats
      sql = <<-SQL
        SELECT name as category, count("taxonID") FROM (
        SELECT distinct("taxonID"), name
        FROM "asvs"
        JOIN "ncbi_nodes" ON "ncbi_nodes"."taxon_id" = "asvs"."taxonID"
        JOIN "ncbi_divisions" ON "ncbi_divisions"."id" = "ncbi_nodes"."cal_division_id"
        JOIN research_project_sources ON sourceable_id = extraction_id
        WHERE (research_project_sources.sourceable_type = 'Extraction')
      SQL
      sql += 'AND (research_project_sources.research_project_id = ' \
        "#{conn.quote(project.id)})"

      sql += <<-SQL
        ORDER BY name
        ) AS foo
        GROUP BY name;
      SQL

      conn.exec_query(sql)
    end

    def gbif_stats
      observations = gbif_occurrences.count
      unique_organisms =
        GbifOccurrence
        .select('DISTINCT(taxonkey)')
        .joins(:research_project_sources)
        .where("research_project_sources.sourceable_type = 'GbifOccurrence'")
        .where("metadata ->> 'location' != 'Montara SMR'")
        .where('research_project_sources.research_project_id = ?', project.id)
        .count

      {
        occurrences: observations,
        organisms: unique_organisms
      }
    end

    def cal_stats
      samples = ResearchProjectSource.cal.where(research_project: project).count
      unique_organisms =
        Asv
        .select('DISTINCT("taxonID")')
        .joins('JOIN research_project_sources ON sourceable_id = extraction_id')
        .where("research_project_sources.sourceable_type = 'Extraction'")
        .where('research_project_sources.research_project_id = ?', project.id)
        .count

      {
        occurrences: samples,
        organisms: unique_organisms
      }
    end

    def gbif_occurrences
      ids =
        ResearchProjectSource
        .gbif
        .where(research_project: project)
        .where("metadata ->> 'location' != 'Montara SMR'")
        .pluck(:sourceable_id)

      GbifOccurrence.where(gbifid: ids)
    end

    def taxon_rank_value
      conn.quote(taxon_rank)
    end

    def taxon_rank_field
      taxon_rank == 'class' ? 'classname' : conn.quote_column_name(taxon_rank)
    end

    def gbif_select_sql
      <<-SQL
      SELECT count(*),
      gbif_taxa.taxonkey as gbif_id, external_resources.ncbi_id,
      asvs."taxonID" as asvs_taxon_id,
      gbif_taxa.kingdom, gbif_taxa.phylum, gbif_taxa.classname,
      gbif_taxa.order, gbif_taxa.family, gbif_taxa.genus, gbif_taxa.species,
      ncbi_nodes.lineage, ncbi_nodes.rank as ncbi_rank
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
        AND ncbi_id IS NOT NULL
        AND source = 'globalnames'
      LEFT JOIN ncbi_nodes
        ON ncbi_nodes.taxon_id = ncbi_id
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
      ncbi_nodes.lineage, ncbi_nodes.rank
      ORDER BY #{sort_fields};
      SQL
    end

    def gbif_taxa
      @gbif_taxa ||= begin
        sql = gbif_select_sql
        sql += gbif_group_sql
        conn.exec_query(sql)
      end
    end

    def gbif_taxa_with_edna
      @gbif_taxa_with_edna ||= begin
        sql = gbif_select_sql
        sql += <<-SQL
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
        sql += gbif_group_sql

        conn.exec_query(sql)
      end
    end

    def sort_fields
      if sort_by == 'count'
        'count(*) DESC'
      else
        'gbif_taxa.kingdom, gbif_taxa.phylum, gbif_taxa.classname, ' \
        'gbif_taxa.order, gbif_taxa.family, gbif_taxa.genus, gbif_taxa.species'
      end
    end

    def globi_target_taxon
      request = GlobiRequest.find(globi_id)
      taxon_name = conn.quote(request.taxon_name)
      node = NcbiNode.find(request.taxon_id)

      sql = <<-SQL
      select #{taxon_name} as taxon_name,
      #{conn.quote(node.full_taxonomy_string)} as taxon_path,
      #{conn.quote(node.rank)} as taxon_rank,
      #{taxon_name} IN(
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
      #{taxon_name} IN(
        SELECT  unnest(string_to_array(full_taxonomy_string, ';'))
        FROM research_project_sources
        JOIN asvs
        ON asvs.extraction_id = research_project_sources.sourceable_id
        JOIN ncbi_nodes
        ON ncbi_nodes.taxon_id = asvs."taxonID"
        WHERE research_project_id = #{project.id}
        AND sourceable_type = 'Extraction'
      ) as edna_match;
      SQL

      results = conn.exec_query(sql)
      results.to_hash.first
    end

    def globi_interactions
      sql = <<-SQL
      SELECT DISTINCT
      interaction_type, target_taxon_external_id,
      target_taxon_name, target_taxon_path,
      (target_taxon_name IN
        (SELECT  unnest(string_to_array(full_taxonomy_string, ';'))
        FROM research_project_sources
        JOIN asvs
        ON asvs.extraction_id = research_project_sources.sourceable_id
        JOIN ncbi_nodes
        ON ncbi_nodes.taxon_id = asvs."taxonID"
        WHERE research_project_id = #{project.id}
        AND sourceable_type = 'Extraction'
        INTERSECT
        SELECT (target_taxon_name)
        FROM external.globi_interactions
        WHERE globi_request_id = #{globi_id})) AS edna_match,
      (target_taxon_name IN
        (SELECT unnest(array[kingdom, phylum, classname, "order", family,
        genus, species])
        FROM research_project_sources
        JOIN external.gbif_occurrences
        ON external.gbif_occurrences.gbifid =
          research_project_sources.sourceable_id
        WHERE research_project_id = #{project.id}
        AND sourceable_type = 'GbifOccurrence'
        AND metadata ->> 'location' != 'Montara SMR'
        INTERSECT
        SELECT (target_taxon_name)
        FROM external.globi_interactions
        WHERE globi_request_id = #{globi_id})) AS gbif_match
      FROM external.globi_interactions
      WHERE globi_request_id = #{globi_id}
      ORDER BY interaction_type, target_taxon_name
      SQL

      conn.exec_query(sql)
    end
  end
end
# rubocop:enable Metrics/MethodLength
