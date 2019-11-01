# frozen_string_literal: true

require 'rails_helper'

describe 'InatObservations' do
  describe 'index' do
    it 'returns OK' do
      get api_v1_inat_observations_path

      expect(response.status).to eq(200)
    end
  end
end
