# frozen_string_literal: true

require 'rails_helper'

describe 'Taxa' do
  before do
    create(:website, name: Website::DEFAULT_SITE)
    create(:research_project, name: 'Los Angeles River')
  end

  describe 'taxa index page' do
    it 'returns OK when there are no taxa' do
      get taxa_path

      expect(response.status).to eq(200)
    end

    it 'returns OK when there are taxa' do
      plant = create(:ncbi_division, name: 'Plantae')
      create(
        :ncbi_node,
        cal_division_id: plant.id,
        hierarchy_names: { phylum: 'Streptophyta' },
        asvs_count: 10
      )
      animal = create(:ncbi_division, name: 'Animalia')
      create(
        :ncbi_node,
        cal_division_id: animal.id,
        hierarchy_names: { kingdom: 'Metazoa' },
        asvs_count: 10
      )

      get taxa_path

      expect(response.status).to eq(200)
    end
  end

  describe 'taxa show page' do
    it 'returns OK for valid id' do
      VCR.use_cassette 'taxa show' do
        taxon =
          create(:ncbi_node, taxon_id: 10, canonical_name: 'abc')
        get taxon_path(id: taxon.id)

        expect(response.status).to eq(200)
      end
    end

    it 'raises an error invalid id' do
      expect { get taxon_path(id: 1) }
        .to raise_error(ActiveRecord::RecordNotFound)
    end
  end
end
