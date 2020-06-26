# frozen_string_literal: true

require 'rails_helper'

describe 'PillarPoint' do
  before do
    create(:website, name: Website::DEFAULT_SITE)
  end

  let(:slug) { 'pillar-point' }
  let!(:research_project) { create(:research_project, slug: slug) }

  describe 'sites' do
    xit 'returns OK' do
      get api_v1_research_projects_pillar_point_sites_path(slug: slug)

      expect(response.status).to eq(200)
    end
  end

  describe 'common_taxa_map' do
    xit 'returns OK' do
      get api_v1_research_projects_pillar_point_common_taxa_map_path(slug: slug)

      expect(response.status).to eq(200)
    end
  end

  describe 'area_diversity' do
    xit 'returns OK' do
      get api_v1_research_projects_pillar_point_area_diversity_path(slug: slug)

      expect(response.status).to eq(200)
    end
  end

  describe 'taxonomy_comparison' do
    xit 'returns OK' do
      get api_v1_research_projects_pillar_point_taxonomy_comparison_path(
        slug: slug
      )

      expect(response.status).to eq(200)
    end
  end

  describe 'biodiversity_bias' do
    xit 'returns OK' do
      get api_v1_research_projects_pillar_point_biodiversity_bias_path(
        slug: slug
      )

      expect(response.status).to eq(200)
    end
  end

  describe 'occurrences' do
    xit 'returns OK' do
      get api_v1_research_projects_pillar_point_occurrences_path(slug: slug)

      expect(response.status).to eq(200)
    end
  end
end
