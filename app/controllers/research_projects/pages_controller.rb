# frozen_string_literal: true

module ResearchProjects
  class PagesController < ApplicationController
    include BatchData
    include PaginatedSamples

    def show
      @project = project
      @page = project_page
      la_river_view if project_slug == 'los-angeles-river'
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

    def project_page
      @project_page ||= begin
        slug = params[:id]
        Page.where(research_project: project, slug: slug).first
      end
    end

    def project
      @project ||= ResearchProject.find_by(slug: project_slug)
    end

    def project_slug
      params[:research_project_id]
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
  end
end