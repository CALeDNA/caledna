# frozen_string_literal: true

module Api
  module V1
    module ResearchProjects
      class PillarPointController < Api::V1::ApplicationController
        before_action :add_cors_headers
        include FilterSamples
        include ResearchProjectService::PillarPointServices

        def sites
          render json: sites_data, status: :ok
        end

        def common_taxa_map
          render json: common_taxa_data, status: :ok
        end

        def area_diversity
          render json: pp.area_diversity_data, status: :ok
        end

        def taxonomy_comparison
          render json: pp.taxonomy_comparison_data, status: :ok
        end

        def biodiversity_bias
          render json: pp.biodiversity_bias, status: :ok
        end

        def occurrences
          render json: {
            occurrences: pp.division_counts,
            unique_taxa: pp.division_counts_unique
          }, status: :ok
        end

        private

        # =======================
        # shared
        # =======================

        def project
          @project ||= ResearchProject.find_by(slug: params[:slug])
        end

        def pp
          @pp ||=
            ResearchProjectService::PillarPoint.new(project, params)
        end

        # =======================
        # sites
        # =======================

        def sites_data
          {
            samples:  { data: pp_samples },
            research_project_data: {
              gbif_occurrences: pp_gbif_occurrences
            }
          }
        end

        def pp_samples
          Rails.cache.fetch('pp_samples', expires_in: 1.year) do
            research_project_samples
          end
        end

        def pp_gbif_occurrences
          Rails.cache.fetch('pp_gbif_occurrences', expires_in: 1.year) do
            pp.gbif_occurrences
          end
        end

        # =======================
        # common_taxa_map
        # =======================

        def common_taxa_data
          {
            research_project_data: {
              gbif_occurrences: pp.common_taxa_gbif
            },
            samples: { data: pp.common_taxa_edna }
          }
        end
      end
    end
  end
end
