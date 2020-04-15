# frozen_string_literal: true

require 'rails_helper'

describe ResultTaxon, type: :model do
  describe '#sources_display' do
    it 'returns nil if no sources' do
      taxon = create(:result_taxon, result_sources: [])

      expect(taxon.sources_display).to eq(nil)
    end

    it 'returns research project names and primers when sources is valid' do
      create(:research_project, id: 100, name: 'name1')
      create(:research_project, id: 200, name: 'name2')
      taxon = create(:result_taxon, result_sources: ['100|p1', '200|p2'])

      expect(taxon.sources_display).to eq('name1 - p1, name2 - p2')
    end

    it 'ignores sources that has invalid project id' do
      create(:research_project, id: 100, name: 'name1')
      taxon = create(:result_taxon, result_sources: ['100|p1', '999|foo'])

      expect(taxon.sources_display).to eq('name1 - p1')
    end

    it 'ignores sources that have wrong format' do
      create(:research_project, id: 100, name: 'name1')
      taxon = create(:result_taxon, result_sources: ['100|p1', '100p2'])

      expect(taxon.sources_display).to eq('name1 - p1')
    end
  end
end
