# frozen_string_literal: true

module Api
  module V1
    module ResearchProjects
      class PillarPointController < Api::V1::ApplicationController
        before_action :add_cors_headers
        include FilterSamples
        include ResearchProjectService::PillarPointServices::CommonTaxaMap

        def sites
          render json: sites_data, status: :ok
        end

        def common_taxa_map
          render json: common_taxa_data, status: :ok
        end

        def area_diversity
          render json: project_service.area_diversity_data, status: :ok
        end

        def taxonomy_comparison
          render json: project_service.taxonomy_comparison_data, status: :ok
        end

        def biodiversity_bias
          render json: project_service.biodiversity_bias, status: :ok
        end

        def occurrences
          render json: {
            occurrences: project_service.division_counts,
            unique_taxa: project_service.division_counts_unique
          }, status: :ok
        end

        private

        # =======================
        # shared
        # =======================

        def ncbi_id
          params[:ncbi_id]
        end

        def project
          @project ||= ResearchProject.find_by(slug: params[:slug])
        end

        def taxon
          params[:taxon]&.tr('_', ' ')
        end

        def rank
          return 'phylum' if params[:taxon_rank].blank?
          params[:taxon_rank] == 'class' ? 'class_name' : params[:taxon_rank]
        end

        def project_service
          @project_service ||=
            ResearchProjectService::PillarPoint.new(project, params)
        end

        # =======================
        # sites
        # =======================

        def sites_data
          json = {
            samples: SampleSerializer.new(all_samples)
          }
          json.merge!(gbif_data) if include_research?
          json
        end

        def include_research?
          params[:include_research] == 'true'
        end

        def gbif_data
          pp = ResearchProjectService::PillarPoint.new(project, params)
          occurrences =
            ncbi_id ? pp.gbif_occurrences_by_taxa : pp.gbif_occurrences
          {
            research_project_data: {
              gbif_occurrences: GbifOccurrenceSerializer.new(occurrences)
            }
          }
        end

        def all_samples
          @all_samples ||= research_project_samples
        end

        # =======================
        # common_taxa_map
        # =======================

        # rubocop:disable Metrics/MethodLength
        def common_taxa_data
          {
            research_project_data: {
              gbif_occurrences: {
                data: common_taxa_gbif.map do |record|
                  {
                    id: record['id'],
                    type: 'gbif_occurrence',
                    attributes: record
                  }
                end
              }
            },
            asvs_count: [],
            samples: {
              data: common_taxa_edna.map do |record|
                {
                  id: record['id'],
                  type: 'sample',
                  attributes: record
                }
              end
            }
          }
        end
        # rubocop:enable Metrics/MethodLength
      end
    end
  end
end
