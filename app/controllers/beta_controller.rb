# frozen_string_literal: true

class BetaController < ApplicationController
  def geojson_demo; end

  def map_v2; end

  def ebbe_nielsen
    @project = project
    researcher_view
    # render template: 'beta/e/pillar_point'
  end

  private

  def conn
    @conn ||= ActiveRecord::Base.connection
  end

  # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
  # rubocop:disable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
  def researcher_view
    if params[:section] == 'occurrence_comparsion'
      @division_counts = project_service.division_counts
      @division_counts_unique = project_service.division_counts_unique
    elsif params[:section] == 'gbif_breakdown'
      @gbif_breakdown = project_service.gbif_breakdown
    elsif params[:section] == 'interactions'
      @interactions = project_service.globi_interactions
      @globi_target_taxon = project_service.globi_target_taxon
      @globi_requests = GlobiRequest.all
    elsif params[:view] == 'list'
      @occurrences = occurrences
      @stats = project_service.stats
      @asvs_count = asvs_count
    elsif params[:section] == 'common_taxa'
      @taxon = params[:ncbi_id] ? NcbiNode.find(params[:ncbi_id]) : nil
      @gbif_taxa_with_edna_map = project_service.common_taxa_map
    elsif params[:section] == 'edna_gbif_comparison'
      @gbif_taxa = project_service.gbif_taxa
      @gbif_taxa_with_edna = project_service.gbif_taxa_with_edna
    else
      @stats = project_service.stats
    end
  end
  # rubocop:enable Metrics/AbcSize, Metrics/MethodLength
  # rubocop:enable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity

  def project
    ResearchProject.find_by(name: 'Pillar Point')
  end

  def project_service
    @project_service ||= begin
      ResearchProjectService::EbbeNielsen.new(project, params)
    end
  end
end
