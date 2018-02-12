# frozen_string_literal: true

require 'rails_helper'

describe 'Field Data Projects' do
  describe 'projects index page' do
    it 'returns OK' do
      get field_data_projects_path

      expect(response.status).to eq(200)
    end
  end

  describe 'projects show page' do
    it 'returns OK' do
      project = create(:field_data_project)
      get field_data_project_path(id: project.id)

      expect(response.status).to eq(200)
    end
  end
end
