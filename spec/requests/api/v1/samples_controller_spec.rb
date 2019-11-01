# frozen_string_literal: true

require 'rails_helper'

describe 'Samples' do
  describe 'index' do
    it 'returns OK' do
      get api_v1_samples_path

      expect(response.status).to eq(200)
    end
  end

  describe 'show' do
    it 'returns OK' do
      create(:sample, id: 1, status_cd: 'approved', latitude: 10, longitude: 10)
      get api_v1_sample_path(id: 1)

      expect(response.status).to eq(200)
    end
  end
end
