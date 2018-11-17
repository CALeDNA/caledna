# frozen_string_literal: true

# rubocop:disable Metrics/MethodLength, Metrics/AbcSize
module ResearchProjectService
  class PillarPoint
    include CustomPagination
    include ResearchProjectService::PillarPointServices::Intro
    include ResearchProjectService::PillarPointServices::OccurrencesComparison
    include ResearchProjectService::PillarPointServices::GbifSourceComparison
    include ResearchProjectService::PillarPointServices::GbifEdnaComparison
    include ResearchProjectService::PillarPointServices::CommonTaxaMap
    include ResearchProjectService::PillarPointServices::BioticInteractions
    include ResearchProjectService::PillarPointServices::AreaDiversity
    include ResearchProjectService::PillarPointServices::TaxaFrequency

    attr_reader :project, :taxon_rank, :sort_by, :params,
                :globi_taxon

    def initialize(project, params)
      @project = project
      @taxon_rank = params[:taxon_rank] || 'phylum'
      @sort_by = params[:sort]
      @params = params
      @globi_taxon = params[:taxon]&.tr('+', ' ')
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

    private

    def conn
      @conn ||= ActiveRecord::Base.connection
    end

    def convert_counts(results)
      counts = {}
      results.to_a.map do |result|
        counts[result['category']] = result['count']
      end
      counts
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

    def limit
      48
    end

    def count_sql
      <<-SQL
      SELECT COUNT(*)
      FROM external.globi_requests
      JOIN research_project_sources
      ON research_project_sources.sourceable_id = external.globi_requests.id
      WHERE research_project_id = #{project.id}
      AND sourceable_type = 'GlobiRequest'
      SQL
    end

    def query_results(sql_string)
      results = conn.exec_query(sql_string)
      results.to_hash
    end
  end
end
# rubocop:enable Metrics/MethodLength, Metrics/AbcSize
