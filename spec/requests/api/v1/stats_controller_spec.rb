# frozen_string_literal: true

require 'rails_helper'

describe 'Stats' do
  describe 'home_page' do
    it 'returns OK' do
      get home_page_api_v1_stats_path

      expect(response.status).to eq(200)
    end
  end
end
