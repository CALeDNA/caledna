# frozen_string_literal: true

# rubocop:disable Metrics/MethodLength, Metrics/AbcSize
# rubocop:disable Metrics/PerceivedComplexity
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
        ORDER BY kingdom
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
        GROUP BY kingdom
        ORDER BY kingdom;
      SQL

      conn.exec_query(sql)
    end

    def inat_division_unique_stats
      sql = gbif_unique_sql
      sql += 'AND (research_project_sources.research_project_id =  ' \
        "#{conn.quote(project.id)}) "

      sql += <<-SQL
          AND (metadata ->> 'location' != 'Montara SMR')
          AND external.gbif_occurrences.datasetkey =
            '50c9509d-22c7-4a22-a47d-8c48425ef4a7'
          ORDER BY kingdom
        ) AS foo
        GROUP BY kingdom
        ORDER BY kingdom;
      SQL
      conn.exec_query(sql)
    end

    def exclude_inat_division_unique_stats
      sql = gbif_unique_sql
      sql += 'AND (research_project_sources.research_project_id =  ' \
        "#{conn.quote(project.id)}) "

      sql += <<-SQL
          AND (metadata ->> 'location' != 'Montara SMR')
          AND external.gbif_occurrences.datasetkey !=
            '50c9509d-22c7-4a22-a47d-8c48425ef4a7'
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
        JOIN "ncbi_divisions"
        ON "ncbi_divisions"."id" = "ncbi_nodes"."cal_division_id"
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

    def gbif_occurrences_by_taxa
      taxon = GbifOccTaxa.find_by(taxonkey: params[:gbif_id])
      rank = taxon.taxonrank == 'class' ? 'classname' : taxon.taxonrank
      name = taxon.send(rank.to_s)

      sql = <<-SQL
      SELECT gbifid
      FROM research_project_sources
      JOIN external.gbif_occurrences
      ON research_project_sources.sourceable_id =
        external.gbif_occurrences.gbifid
      WHERE sourceable_type = 'GbifOccurrence'
      AND research_project_id = #{project.id}
      AND metadata ->> 'location' != 'Montara SMR'
      SQL

      sql += if rank == 'order'
               "AND \"order\" = #{conn.quote(name)};"
             else
               "AND #{rank} = #{conn.quote(name)};"
             end

      ids = conn.exec_query(sql).rows.flatten
      GbifOccurrence.where(gbifid: ids)
    end

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
      ncbi_nodes.hierarchy_names, ncbi_nodes.rank
      ORDER BY #{sort_fields};
      SQL
    end

    def gbif_taxa
      @gbif_taxa ||= begin
        sql = gbif_fields_sql
        sql += gbif_select_sql
        sql += gbif_group_sql
        conn.exec_query(sql)
      end
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

    def gbif_taxa_with_edna
      @gbif_taxa_with_edna ||= begin
        sql = gbif_fields_sql
        sql += gbif_select_sql
        sql += gbif_taxa_with_edna_sql
        sql += gbif_group_sql

        conn.exec_query(sql)
      end
    end

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

    def sort_fields
      if sort_by == 'count'
        'count(*) DESC'
      else
        'gbif_taxa.kingdom, gbif_taxa.phylum, gbif_taxa.classname, ' \
        'gbif_taxa.order, gbif_taxa.family, gbif_taxa.genus, gbif_taxa.species'
      end
    end

    def globi_target_taxon
      return unless globi_id

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
      return [] unless globi_id

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

    def area_diversity_gbif_sql
      sql = <<-SQL
        SELECT taxonkey
        FROM external.gbif_occurrences
        JOIN research_project_sources
        ON research_project_sources.sourceable_id =
          external.gbif_occurrences.gbifid
        WHERE sourceable_type = 'GbifOccurrence'
        AND research_project_id = #{project.id}
      SQL

      if taxon_groups
        taxa = taxon_groups
               .gsub('plants', 'Plantae')
               .gsub('animals', 'Animalia')
               .gsub('fungi', 'Fungi')
               .gsub('bacteria', 'Bacteria')

        filters = taxa.split('|')
        sql += " AND kingdom in (#{filters.to_s[1..-2].tr('"', "'")})"
      end

      if months
        filters = months.split('|')

        if filters.length == 1
          month = filters.first
          sql += if month == 'february'
                   ' AND month = 2'
                 else
                   ' AND month = 4'
                 end
        elsif filters.length > 1
          sql += ' AND (month = 2 OR month = 4)'
        end
      end
      sql
    end

    def taxon_groups
      params['taxon_groups']
    end

    def months
      params['months']
    end

    def area_diversity_cal_sql
      @area_diversity_cal_sql = begin
        sql = <<-SQL
          SELECT asvs."taxonID"
          FROM asvs
          JOIN ncbi_nodes
          ON asvs."taxonID" = ncbi_nodes.taxon_id
          JOIN research_project_sources
          ON research_project_sources.sourceable_id = asvs.extraction_id
          JOIN samples
          ON asvs.sample_id = samples.id
          WHERE sourceable_type = 'Extraction'
          AND research_project_id = #{project.id}
        SQL

        if taxon_groups
          taxa = taxon_groups
                 .gsub('plants', '14|4')
                 .gsub('animals', '12')
                 .gsub('fungi', '13')
                 .gsub('bacteria', '0|9|16')

          filters = taxa.split('|').join(', ')
          sql += " AND ncbi_nodes.cal_division_id in (#{filters})"
        end

        if months
          filters = months.split('|').map(&:titlecase)
          sql += " AND samples.metadata ->> 'month' in"
          sql + " (#{filters.to_s[1..-2].tr('"', "'")})"
        end
        sql
      end
    end

    def area_diversity_cal_location(location)
      sql = area_diversity_cal_sql
      sql += " AND research_project_sources.metadata ->> 'location'"
      sql + " = '#{location}'"
    end

    def area_diversity_gbif_location(location)
      sql = area_diversity_gbif_sql
      sql += " AND research_project_sources.metadata ->> 'location'"
      sql + " = '#{location}'"
    end

    def query_results(sql_string)
      results = conn.exec_query(sql_string)
      results.to_hash
    end

    def cal_location(*locations)
      sql_array = locations.map { |l| area_diversity_cal_location(l) }
      sql_string = sql_array.join(' INTERSECT ')
      sql_string = <<-SQL
      SELECT COUNT(DISTINCT("taxonID")) FROM (
        #{sql_string}
      ) AS foo
      SQL

      query_results(sql_string).first['count']
    end

    def gbif_location(*locations)
      sql_array = locations.map { |l| area_diversity_gbif_location(l) }
      sql_string = sql_array.join(' INTERSECT ')
      sql_string = <<-SQL
      SELECT COUNT(DISTINCT(taxonkey)) FROM (
        #{sql_string}
      ) AS foo
      SQL

      query_results(sql_string).first['count']
    end

    def gbif_total
      sql_string = area_diversity_gbif_sql
      sql_string += "AND metadata ->> 'location' != 'Montara SMR'"
      sql_string = <<-SQL
      SELECT COUNT(DISTINCT(taxonkey)) FROM (
        #{sql_string}
      ) AS foo
      SQL

      query_results(sql_string).first['count']
    end

    def cal_total
      sql_string = area_diversity_cal_sql
      sql_string = <<-SQL
      SELECT COUNT(DISTINCT("taxonID")) FROM (
        #{sql_string}
      ) AS foo
      SQL

      query_results(sql_string).first['count']
    end

    def area_diversity_data
      smca = 'Pillar Point SMCA'
      exposed = 'Pillar Point exposed unprotected'
      embankment = 'Pillar Point embankment unprotected'

      {
        cal: {
          total: cal_total,
          locations: [
            { names: [smca], count: cal_location(smca) },
            { names: [exposed], count: cal_location(exposed) },
            { names: [embankment], count: cal_location(embankment) },
            { names: [smca, exposed], count: cal_location(smca, exposed) },
            {
              names: [embankment, exposed],
              count: cal_location(embankment, exposed)
            },
            {
              names: [smca, embankment],
              count: cal_location(smca, embankment)
            },
            {
              names: [smca, embankment, exposed],
              count: cal_location(smca, embankment, exposed)
            }
          ]
        },
        gbif: {
          total: gbif_total,
          locations: [
            { names: [smca], count: gbif_location(smca) },
            { names: [exposed], count: gbif_location(exposed) },
            { names: [embankment], count: gbif_location(embankment) },
            { names: [smca, exposed], count: gbif_location(smca, exposed) },
            {
              names: [embankment, exposed],
              count: gbif_location(embankment, exposed)
            },
            {
              names: [smca, embankment],
              count: gbif_location(smca, embankment)
            },
            {
              names: [smca, embankment, exposed],
              count: gbif_location(smca, embankment, exposed)
            }
          ]
        }
      }
    end
  end
end
# rubocop:enable Metrics/MethodLength, Metrics/AbcSize
# rubocop:enable Metrics/PerceivedComplexity
