# frozen_string_literal: true

require 'rails_helper'

describe 'Research Projects' do
  before(:each) do
    create(:website, name: Website::DEFAULT_SITE)
  end

  describe 'projects index page' do
    it 'returns OK when there are no projects' do
      get research_projects_path

      expect(response.status).to eq(200)
    end

    it 'returns OK when there are projects' do
      create(:research_project)
      get research_projects_path

      expect(response.status).to eq(200)
    end
  end

  describe 'projects show page' do
    it 'returns OK for valid id' do
      project = create(:research_project, slug: 'slug')
      get research_project_path(id: project.slug)

      expect(response.status).to eq(200)
    end

    it 'page contains h1 for valid id' do
      project = create(:research_project, slug: 'slug')
      get research_project_path(id: project.slug)

      expect(response.body).to include('<h1>')
    end

    it 'returns ok for invaid id' do
      get research_project_path(id: 1)

      expect(response.status).to eq(200)
    end

    it 'page does not contain h1 for invalid id' do
      get research_project_path(id: 1)

      expect(response.body).to_not include('<h1>')
    end
  end
end
