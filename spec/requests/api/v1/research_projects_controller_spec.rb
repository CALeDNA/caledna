# frozen_string_literal: true

require 'rails_helper'

describe 'ResearchProjects' do
  describe 'index' do
    it 'returns OK' do
      create(:research_project, slug: 'project-slug')
      get api_v1_research_project_path(id: 'project-slug')

      expect(response.status).to eq(200)
    end
  end
end
