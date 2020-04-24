# frozen_string_literal: true

require 'rails_helper'

describe 'Primers' do
  describe 'index' do
    it 'returns OK' do
      get api_v1_primers_path

      expect(response.status).to eq(200)
    end
  end
end
