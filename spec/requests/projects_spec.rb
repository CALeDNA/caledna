# frozen_string_literal: true

require 'rails_helper'

describe 'Projects' do
  describe 'projects index page' do
    it 'returns OK' do
      get projects_path

      expect(response.status).to eq(200)
    end
  end

  describe 'projects show page' do
    it 'returns OK' do
      project = create(:project)
      get project_path(id: project.id)

      expect(response.status).to eq(200)
    end
  end
end
