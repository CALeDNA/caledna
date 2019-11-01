# frozen_string_literal: true

require 'rails_helper'

describe 'Taxa' do
  describe 'index' do
    it 'returns OK' do
      get api_v1_taxa_path(query: 'foo')

      expect(response.status).to eq(200)
    end
  end

  describe 'show' do
    it 'returns OK' do
      create(:ncbi_node, ids: [1], id: 1)
      get api_v1_taxon_path(id: 1)

      expect(response.status).to eq(200)
    end
  end
end
