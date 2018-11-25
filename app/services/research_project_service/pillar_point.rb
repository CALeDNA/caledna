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
    include ResearchProjectService::PillarPointServices::SourceComparisonAll

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
      GbifOccurrence
        .joins(:research_project_sources)
        .where('research_project_sources.research_project_id = ?', project.id)
        .where("metadata ->> 'location' != 'Montara SMR'")
        .where('kingdom is not null')
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

    def gbif_taxon_rank_field
      taxon_rank == 'class' ? 'classname' : taxon_rank
    end

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
        SELECT COUNT(DISTINCT(taxonkey)), kingdom AS category
        FROM external.gbif_occurrences
        JOIN research_project_sources
        ON research_project_sources.sourceable_id =
          external.gbif_occurrences.gbifid
        WHERE (research_project_sources.sourceable_type = 'GbifOccurrence')
        AND (research_project_sources.research_project_id =
        #{conn.quote(project.id)})
        AND (metadata ->> 'location' != 'Montara SMR')
        AND kingdom IS NOT NULL
      SQL
    end

    def taxon_groups
      params['taxon_groups']
    end

    def selected_taxon_groups_ids
      taxa = taxon_groups
             .gsub('plants', '14|4')
             .gsub('animals', '12')
             .gsub('fungi', '13')
             .gsub('bacteria', '0|9')
             .gsub('archaea', '16')
             .gsub('chromista', '17')

      taxa.split('|').join(', ')
    end

    def selected_taxon_groups
      taxa = taxon_groups
             .gsub('plants', 'Plantae')
             .gsub('animals', 'Animalia')
             .gsub('fungi', 'Fungi')
             .gsub('bacteria', 'Bacteria')
             .gsub('archaea', 'Archaea')
             .gsub('chromista', 'Chromista')

      taxa.split('|')
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
