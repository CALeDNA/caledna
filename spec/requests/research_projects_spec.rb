# frozen_string_literal: true

require 'rails_helper'

describe 'Research Projects' do
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
      project = create(:research_project)
      get research_project_path(id: project.id)

      expect(response.status).to eq(200)
    end

    xit 'raises an error invalid id' do
      expect { get research_project_path(id: 1) }
        .to raise_error(ActiveRecord::RecordNotFound)
    end
  end
end
