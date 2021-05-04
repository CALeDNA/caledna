# frozen_string_literal: true

module ResearchProjectService
  class LaRiver
    include ResearchProjectService::LaRiverServices::OccurrencesComparison
    include ResearchProjectService::LaRiverServices::AreaDiversity
    include ResearchProjectService::LaRiverServices::DetectionFrequency
    include ResearchProjectService::LaRiverServices::IdentifiedSpecies
    include ResearchProjectService::LaRiverServices::Intro

    attr_reader :projects, :project, :taxon_rank, :sort_by, :params,
                :globi_taxon

    def initialize(projects, params)
      if projects.class == ResearchProject
        @projects = nil
        @project = projects
      else
        @projects = projects
        @project = nil
      end

      @taxon_rank = params[:taxon_rank] || 'phylum'
      @sort_by = params[:sort]
      @params = params
      @globi_taxon = params[:taxon]&.tr('+', ' ')
    end

    private

    def combine_taxon_rank_field
      taxon_rank == 'class' ? 'class_name' : taxon_rank
    end

    def inat_taxon_rank_field
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

    def taxon_groups
      params['taxon_groups']
    end

    def selected_taxon_groups
      taxon_groups.split('|').to_s[1..-2].tr('"', "'")
    end

    def query_results(sql_string)
      results = conn.exec_query(sql_string)
      results.entries
    end
  end
end
