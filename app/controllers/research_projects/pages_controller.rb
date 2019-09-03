# frozen_string_literal: true

module ResearchProjects
  class PagesController < ApplicationController
    include BatchData
    include PaginatedSamples

    def show
      @project = project
      @page = project_page
      la_river_view if project_slug == 'los-angeles-river'
      pillar_point_view if project_slug == 'pillar-point'
    end

    def edit
      redirect_to research_projects_path unless current_researcher

      @page = Page.find_by(research_project: project, slug: page_slug)
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
        Page.where(research_project: project, slug: page_slug).first
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
        if params[:taxon]
          @interactions = pillar_point_service.globi_interactions
          @globi_target_taxon = pillar_point_service.globi_target_taxon
        else
          @taxon_list = pillar_point_service.globi_index
        end
      elsif params[:view] == 'list'
        @occurrences = occurrences
        @stats = pillar_point_service.stats
        @asvs_count = asvs_count
      elsif params[:id] == 'common_taxa'
        @taxon = params[:taxon]
        @gbif_taxa_with_edna_map = pillar_point_service.common_taxa_map
      elsif params[:id] == 'edna_gbif_comparison'
        @gbif_taxa = pillar_point_service.gbif_taxa
      elsif params[:id] == 'intro'
        @stats = pillar_point_service.stats
      end

      render 'research_projects/pillar_point'
    end
    # rubocop:enable Metrics/AbcSize, Metrics/MethodLength
    # rubocop:enable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity

    def pillar_point_service
      @pillar_point_service ||= begin
        ResearchProjectService::PillarPoint.new(project, params)
      end
    end
  end
end