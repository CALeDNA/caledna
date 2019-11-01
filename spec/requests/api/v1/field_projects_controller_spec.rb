# frozen_string_literal: true

require 'rails_helper'

describe 'FieldProjecs' do
  describe 'show' do
    it 'returns OK' do
      create(:field_project, id: 1)
      get api_v1_field_project_path(id: 1)

      expect(response.status).to eq(200)
    end
  end
end
