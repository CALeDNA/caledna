# frozen_string_literal: true

require 'rails_helper'

describe 'Field Projects' do
  before do
    create(:website, name: Website::DEFAULT_SITE)
  end

  describe 'projects index page' do
    xit 'returns OK when there are no projects' do
      get field_projects_path

      expect(response.status).to eq(200)
    end

    xit 'returns OK when there are projects' do
      create(:field_project)
      get field_projects_path

      expect(response.status).to eq(200)
    end
  end

  describe 'projects show page' do
    xit 'returns OK for valid id' do
      project = create(:field_project)
      get field_project_path(id: project.id)

      expect(response.status).to eq(200)
    end

    xit 'raises an error invalid id' do
      expect { get field_project_path(id: 1) }
        .to raise_error(ActiveRecord::RecordNotFound)
    end
  end
end
