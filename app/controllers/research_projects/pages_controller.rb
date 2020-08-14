# frozen_string_literal: true

module ResearchProjects
  class PagesController < ApplicationController
    include BatchData
    include PaginatedSamples
    include CheckWebsite
    include CustomPagination

    layout 'river/application' if CheckWebsite.pour_site?

    def show
      @project = project
      @page = project_page
      if project_slug == 'los-angeles-river'
        la_river_view
      elsif project_slug == 'pillar-point'
        pillar_point_view
      else
        default_view
      end
    end

    def edit
      redirect_to research_projects_path unless current_researcher

      @page = ResearchProjectPage.find_by(research_project: project,
                                          slug: page_slug)
    end

    def update
      if current_researcher && project_page.update(raw_params)
        redirect_to redirect_path
      else
        flash[:error] = 'Something went wrong. Changes not saved'
        redirect_to request.referrer
      end
    end

    private

    # =======================
    # show
    # =======================

    def counts
      @counts ||= list_view? ? asvs_count : []
    end

    def samples
      @samples ||= list_view? ? paginated_samples : []
    end

    def paginated_samples
      @paginated_samples ||= research_project_paginated_samples(project.id)
    end

    # =======================
    # edit
    # =======================

    def redirect_path
      research_project_page_path(research_project_id: project_slug,
                                 id: page_slug)
    end

    # =======================
    # common
    # =======================

    def project_page
      @project_page ||= begin
        ResearchProjectPage.where(research_project: project, slug: page_slug)
                           .where(published: true)
                           .first
      end
    end

    def project
      @project ||= ResearchProject.find_by(slug: project_slug)
    end

    def project_slug
      params[:research_project_id]
    end

    def page_slug
      params[:id]
    end

    def raw_params
      params.require(:page)
            .permit(:body, :title)
    end

    # =======================
    # default
    # =======================

    def default_view
      return unless params[:view] == 'list'
      @samples = samples
      @asvs_count = asvs_count
    end

    # =======================
    # LA river
    # =======================

    # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
    def la_river_view
      if params[:id] == 'overview'
        @division_counts = la_river_service.division_counts
        @division_counts_unique = la_river_service.division_counts_unique
      elsif params[:id] == 'sites'
        @samples = samples
        @asvs_count = counts
      elsif params[:id] == 'plants-animals'
        @identified_species_by_location =
          la_river_service.identified_species_by_location
      elsif params[:id] == 'intro'
        @stats = la_river_service.stats
      end

      render 'research_projects/la_river'
    end
    # rubocop:enable Metrics/AbcSize, Metrics/MethodLength

    def la_river_service
      @la_river_service ||= begin
        ResearchProjectService::LaRiver.new(project, params)
      end
    end

    # =======================
    # pillar point
    # =======================

    # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
    # rubocop:disable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
    def pillar_point_view
      if params[:id] == 'occurrence_comparison'
        @division_counts = pillar_point_service.division_counts
        @division_counts_unique = pillar_point_service.division_counts_unique
      elsif params[:id] == 'gbif_breakdown'
        @gbif_breakdown = pillar_point_service.gbif_breakdown
      elsif params[:id] == 'interactions'
        if pp_taxon
          sql = 'edna_match DESC, gbif_match DESC, interaction_type'
          @interactions = PpGlobiShow.where(keyword: pp_taxon).order(sql)
          @globi_target_taxon = pillar_point_service.globi_target_taxon
        else
          @taxon_list = PpGlobiIndex.page(params[:page]).per(48)
        end
      elsif params[:view] == 'list'
        @occurrences = samples.page(params[:page])
        @stats = pillar_point_service.stats
        @asvs_count = asvs_count
      elsif params[:id] == 'common_taxa'
        @taxon = pp_taxon
        @gbif_taxa_with_edna_map = pillar_point_service.common_taxa_map
      elsif params[:id] == 'edna_gbif_comparison'
        order = params[:sort] == 'count' ?  'count DESC' : 'id ASC'
        @gbif_taxa = PpEdnaGbif.where(rank: pp_rank).order(order)
                               .page(params[:page]).per(50)
        @gbif_taxa_count = PpEdnaGbif.where(rank: pp_rank).count
        @gbif_taxa_with_ncbi_count =
          PpEdnaGbif.where(rank: pp_rank, ncbi_match: true).count
        @gbif_taxa_with_edna_count =
          PpEdnaGbif.where(rank: pp_rank, edna_match: true).count

      elsif params[:id] == 'intro'
        @stats = pillar_point_service.stats
      end

      render 'research_projects/pillar_point'
    end
    # rubocop:enable Metrics/AbcSize, Metrics/MethodLength
    # rubocop:enable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity

    def pp_rank
      rank_param = params[:taxon_rank]
      NcbiNode::TAXON_RANKS_PHYLUM.include?(rank_param) ? rank_param : 'phylum'
    end

    def pp_taxon
      params[:taxon]
    end

    def pillar_point_service
      @pillar_point_service ||= begin
        ResearchProjectService::PillarPoint.new(project, params)
      end
    end
  end
end
