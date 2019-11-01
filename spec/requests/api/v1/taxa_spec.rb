# frozen_string_literal: true

require 'rails_helper'

describe 'api/v1/taxa' do
  describe 'index' do
    it 'returns OK' do
      get api_v1_taxa_path

      expect(response.status).to eq(200)
    end

    it 'returns empty array if no match' do
      create(:ncbi_node, canonical_name: 'random')

      get api_v1_taxa_path(query: 'MatCH')
      json = JSON.parse(response.body)

      expect(json['data'].length).to eq(0)
    end

    it 'returns taxa that has exact canonical_name match' do
      create(:ncbi_node, canonical_name: 'random', id: 1)
      create(:ncbi_node, canonical_name: 'match', id: 2)
      create(:ncbi_node, canonical_name: 'match', id: 3)

      get api_v1_taxa_path(query: 'MatCH')
      data = JSON.parse(response.body)['data']

      expect(data.length).to eq(2)

      ids = data.map { |i| i['id'] }
      expect(ids).to match_array(%w[2 3])
    end

    it 'returns taxa that has canonical_name prefix match' do
      create(:ncbi_node, canonical_name: 'xx match', id: 1)
      create(:ncbi_node, canonical_name: 'match', id: 2)
      create(:ncbi_node, canonical_name: 'match xx', id: 3)

      get api_v1_taxa_path(query: 'MatCH')
      data = JSON.parse(response.body)['data']

      expect(data.length).to eq(2)

      ids = data.map { |i| i['id'] }
      expect(ids).to match_array(%w[2 3])
    end
  end

  describe 'show' do
    def create_asv(taxon, sample)
      extraction = create(:extraction, sample: sample)
      create(:asv, taxonID: taxon.id, sample: sample, extraction: extraction)
    end

    it 'returns OK' do
      taxon = create(:ncbi_node, lineage: [[1, 'name', 'rank']])
      get api_v1_taxon_path(id: taxon.id)

      expect(response.status).to eq(200)
    end

    context '"samples" field' do
      it 'returns samples that contain the the specified taxon' do
        taxon = create(:ncbi_node, id: 1, ids: [1])
        sample_attributes = {
          'id' => 10,
          'latitude' => '10.0',
          'longitude' => '20.0',
          'barcode' => 'k_1',
          'status' => 'results_completed',
          'substrate' => 'soil',
          'primers' => ['12S']
        }
        sample = create(:sample, sample_attributes)
        create_asv(taxon, sample)

        taxon2 = create(:ncbi_node, id: 2, ids: [2])
        sample2 = create(:sample, :results_completed, id: 11)
        create_asv(taxon2, sample2)

        get api_v1_taxon_path(id: taxon.id)
        payload = JSON.parse(response.body)
        samples_payload = payload['samples']['data']

        expect(samples_payload.length).to eq(1)
        expect(samples_payload[0]['attributes']).to eq(sample_attributes)
      end

      context 'substrate params' do
        it 'returns samples when there is one substrate' do
          taxon1 = create(:ncbi_node, id: 1, ids: [1])

          sample1 = create(:sample, :results_completed, id: 10,
                                                        substrate_cd: 's1')
          create_asv(taxon1, sample1)

          sample2 = create(:sample, :results_completed, id: 11,
                                                        substrate_cd: 's2')
          create_asv(taxon1, sample2)

          get api_v1_taxon_path(id: taxon1.id, substrate: 's1')
          payload = JSON.parse(response.body)
          base_samples_payload = payload['samples']['data']
          ids = base_samples_payload.map { |s| s['id'].to_i }

          expect(base_samples_payload.length).to eq(1)
          expect(ids).to match_array([10])
        end

        it 'returns samples when there are multiple substrates' do
          taxon1 = create(:ncbi_node, id: 1, ids: [1])

          sample1 = create(:sample, :results_completed, id: 10,
                                                        substrate_cd: 's1')
          create_asv(taxon1, sample1)

          sample2 = create(:sample, :results_completed, id: 11,
                                                        substrate_cd: 's2')
          create_asv(taxon1, sample2)

          get api_v1_taxon_path(id: taxon1.id, substrate: 's1|s2')
          payload = JSON.parse(response.body)
          base_samples_payload = payload['samples']['data']
          ids = base_samples_payload.map { |s| s['id'].to_i }

          expect(base_samples_payload.length).to eq(2)
          expect(ids).to match_array([10, 11])
        end
      end

      context 'primer query params' do
        before(:each) do
          create(:primer, name: 'p1')
          create(:primer, name: 'p2')
        end

        it 'returns samples when there is one primer' do
          taxon1 = create(:ncbi_node, id: 1, ids: [1])

          sample1 = create(:sample, :results_completed, id: 10, primers: ['p1'])
          create_asv(taxon1, sample1)

          sample2 = create(:sample, :results_completed, id: 11, primers: ['p2'])
          create_asv(taxon1, sample2)

          get api_v1_taxon_path(id: taxon1.id, primer: 'p1')
          payload = JSON.parse(response.body)
          base_samples_payload = payload['samples']['data']
          ids = base_samples_payload.map { |s| s['id'].to_i }

          expect(base_samples_payload.length).to eq(1)
          expect(ids).to match_array([10])
        end

        it 'returns samples when there are multiple primer' do
          taxon1 = create(:ncbi_node, id: 1, ids: [1])

          sample1 = create(:sample, :results_completed, id: 10, primers: ['p1'])
          create_asv(taxon1, sample1)

          sample2 = create(:sample, :results_completed, id: 11, primers: ['p2'])
          create_asv(taxon1, sample2)

          get api_v1_taxon_path(id: taxon1.id, primer: 'p1|p2')
          payload = JSON.parse(response.body)
          base_samples_payload = payload['samples']['data']
          ids = base_samples_payload.map { |s| s['id'].to_i }

          expect(base_samples_payload.length).to eq(2)
          expect(ids).to match_array([10, 11])
        end
      end
    end

    it '"base_samples" returns all samples with results' do
      taxon1 = create(:ncbi_node, id: 1, ids: [1])
      sample1 = create(:sample, :results_completed, id: 10)
      create_asv(taxon1, sample1)

      taxon2 = create(:ncbi_node, id: 2, ids: [2])
      sample2 = create(:sample, :results_completed, id: 11)
      create_asv(taxon2, sample2)

      create(:sample, :valid, id: 12, status: 'approved')

      get api_v1_taxon_path(id: taxon1.id)
      payload = JSON.parse(response.body)
      base_samples_payload = payload['base_samples']['data']
      ids = base_samples_payload.map { |s| s['id'].to_i }

      expect(base_samples_payload.length).to eq(2)
      expect(ids).to match_array([10, 11])
    end
  end
end
