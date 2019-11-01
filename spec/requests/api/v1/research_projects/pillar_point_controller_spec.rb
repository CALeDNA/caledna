# frozen_string_literal: true

require 'rails_helper'

describe 'PillarPoint' do
  let(:slug) { 'pillar-point' }
  let!(:research_project) { create(:research_project, slug: slug) }

  describe 'sites' do
    it 'returns OK' do
      get api_v1_research_projects_pillar_point_sites_path(slug: slug)

      expect(response.status).to eq(200)
    end
  end

  describe 'common_taxa_map' do
    it 'returns OK' do
      get api_v1_research_projects_pillar_point_common_taxa_map_path(slug: slug)

      expect(response.status).to eq(200)
    end
  end

  describe 'area_diversity' do
    it 'returns OK' do
      get api_v1_research_projects_pillar_point_area_diversity_path(slug: slug)

      expect(response.status).to eq(200)
    end
  end

  describe 'source_comparison_all' do
    it 'returns OK' do
      get api_v1_research_projects_pillar_point_source_comparison_all_path(
        slug: slug
      )

      expect(response.status).to eq(200)
    end
  end

  describe 'biodiversity_bias' do
    it 'returns OK' do
      get api_v1_research_projects_pillar_point_biodiversity_bias_path(
        slug: slug
      )

      expect(response.status).to eq(200)
    end
  end

  describe 'occurrences' do
    it 'returns OK' do
      get api_v1_research_projects_pillar_point_occurrences_path(slug: slug)

      expect(response.status).to eq(200)
    end
  end
end
