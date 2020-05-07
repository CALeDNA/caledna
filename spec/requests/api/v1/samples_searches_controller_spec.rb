# frozen_string_literal: true

require 'rails_helper'

describe 'SamplesSearches' do
  before do
    stub_const('Website::DEFAULT_SITE', create(:website, name: 'CALeDNA'))
  end

  describe 'show' do
    it 'returns OK' do
      get api_v1_samples_search_path

      expect(response.status).to eq(200)
    end
  end
end
