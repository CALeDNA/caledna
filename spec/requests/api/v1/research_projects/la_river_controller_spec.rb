# frozen_string_literal: true

require 'rails_helper'

describe 'LaRiver' do
  let(:slug) { 'los-angeles-river' }
  let!(:research_project) { create(:research_project, slug: slug) }

  describe 'sites' do
    it 'returns OK' do
      get api_v1_research_projects_la_river_sites_path(slug: slug)

      expect(response.status).to eq(200)
    end
  end

  describe 'area_diversity' do
    it 'returns OK' do
      get api_v1_research_projects_la_river_area_diversity_path(slug: slug)

      expect(response.status).to eq(200)
    end
  end

  describe 'pa_area_diversity' do
    it 'returns OK' do
      get api_v1_research_projects_la_river_pa_area_diversity_path(slug: slug)

      expect(response.status).to eq(200)
    end
  end

  describe 'sampling_types' do
    it 'returns OK' do
      get api_v1_research_projects_la_river_sampling_types_path(slug: slug)

      expect(response.status).to eq(200)
    end
  end

  describe 'detection_frequency' do
    it 'returns OK' do
      get api_v1_research_projects_la_river_detection_frequency_path(slug: slug)

      expect(response.status).to eq(200)
    end
  end
end
