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
    let(:target_id) { 2 }

    def create_occurence(taxon, substrate: :soil, primers: '12S')
      sample = create(:sample, :results_completed, substrate_cd: substrate,
                                                   primers: primers.split('|'))
      extraction = create(:extraction, sample: sample)
      create(:asv, sample: sample, extraction: extraction,
                   taxonID: taxon.taxon_id)
      sample
    end

    def parse_response(response)
      samples = JSON.parse(response.body)['samples']['data']
      asvs_count = JSON.parse(response.body)['asvs_count']
      base_samples = JSON.parse(response.body)['base_samples']['data']

      [samples, asvs_count, base_samples]
    end

    it 'returns OK' do
      create(:ncbi_node, ids: [target_id], id: target_id)
      get api_v1_taxon_path(id: target_id)

      expect(response.status).to eq(200)
    end

    it 'returns samples that exactly match a given taxon' do
      taxon = create(:ncbi_node, ids: [1, target_id], id: target_id)
      create_occurence(taxon)

      get api_v1_taxon_path(id: target_id)
      samples, asvs_count, base_samples = parse_response(response)

      expect(samples.length).to eq(1)
      expect(asvs_count.length).to eq(1)
      expect(base_samples.length).to eq(1)
    end

    it 'returns samples whose ids contain a given taxon' do
      taxon = create(:ncbi_node, ids: [1, target_id, 3], id: 3)
      create_occurence(taxon)

      get api_v1_taxon_path(id: target_id)
      samples, asvs_count, base_samples = parse_response(response)

      expect(samples.length).to eq(1)
      expect(asvs_count.length).to eq(1)
      expect(base_samples.length).to eq(1)
    end

    it 'ignores samples that contain other taxa' do
      taxon = create(:ncbi_node, ids: [4], id: 4)
      create_occurence(taxon)

      get api_v1_taxon_path(id: target_id)
      samples, asvs_count, base_samples = parse_response(response)

      expect(samples.length).to eq(0)
      expect(asvs_count.length).to eq(1)
      expect(base_samples.length).to eq(1)
    end

    it 'correctly handles a variety of samples' do
      taxon = create(:ncbi_node, ids: [1, target_id], id: target_id)
      sample1 = create_occurence(taxon)

      taxon = create(:ncbi_node, ids: [1, target_id, 3], id: 3)
      sample2 = create_occurence(taxon)

      taxon = create(:ncbi_node, ids: [4], id: 4)
      create_occurence(taxon)

      get api_v1_taxon_path(id: target_id)
      samples, asvs_count, base_samples = parse_response(response)

      expect(samples.length).to eq(2)
      expect(asvs_count.length).to eq(3)
      expect(base_samples.length).to eq(3)

      sample_ids = samples.map { |i| i['attributes']['id'] }
      expect(sample_ids).to eq([sample1.id, sample2.id])
    end

    describe 'substrate query param' do
      before(:each) do
        taxon = create(:ncbi_node, ids: [1, target_id, 3], id: 3)
        create_occurence(taxon, substrate: :soil)
        create_occurence(taxon, substrate: :bad)
        create_occurence(taxon, substrate: :sediment)
      end

      it 'returns samples when there is one substrate' do
        get api_v1_taxon_path(id: target_id, substrate: :soil)
        samples, asvs_count, base_samples = parse_response(response)

        expect(samples.length).to eq(1)
        expect(asvs_count.length).to eq(3)
        expect(base_samples.length).to eq(1)

        substrate = samples.map { |i| i['attributes']['substrate'] }
        expect(substrate).to eq(['soil'])
      end

      it 'returns samples when there is multiple substrate' do
        get api_v1_taxon_path(id: target_id, substrate: 'soil|sediment')
        samples, asvs_count, base_samples = parse_response(response)

        expect(samples.length).to eq(2)
        expect(asvs_count.length).to eq(3)
        expect(base_samples.length).to eq(2)

        substrate = samples.map { |i| i['attributes']['substrate'] }
        expect(substrate).to match_array(%w[sediment soil])
      end

      it 'returns all samples when substrate is all' do
        get api_v1_taxon_path(id: target_id, substrate: 'all')
        samples, asvs_count, base_samples = parse_response(response)

        expect(samples.length).to eq(3)
        expect(asvs_count.length).to eq(3)
        expect(base_samples.length).to eq(3)
      end
    end

    describe 'primer query param' do
      before(:each) do
        taxon = create(:ncbi_node, ids: [1, target_id, 3], id: 3)
        create_occurence(taxon, primers: '12S')
        create_occurence(taxon, primers: '18S')
        create_occurence(taxon, primers: 'bad')
        create(:primer, name: '12S')
        create(:primer, name: '18S')
      end

      it 'returns samples when there is one primer' do
        get api_v1_taxon_path(id: target_id, primer: '12S')
        samples, asvs_count, base_samples = parse_response(response)

        expect(samples.length).to eq(1)
        expect(asvs_count.length).to eq(3)
        expect(base_samples.length).to eq(1)

        primers = samples.map { |i| i['attributes']['primers'] }
        expect(primers).to eq([['12S']])
      end

      it 'returns samples when there is multiple primers' do
        get api_v1_taxon_path(id: target_id, primer: '12S|18S')
        samples, asvs_count, base_samples = parse_response(response)

        expect(samples.length).to eq(2)
        expect(asvs_count.length).to eq(3)
        expect(base_samples.length).to eq(2)

        primers = samples.map { |i| i['attributes']['primers'] }
        expect(primers).to match_array([['12S'], ['18S']])
      end

      it 'returns all samples when primer is all' do
        get api_v1_taxon_path(id: target_id, primer: 'all')
        samples, asvs_count, base_samples = parse_response(response)

        expect(samples.length).to eq(3)
        expect(asvs_count.length).to eq(3)
        expect(base_samples.length).to eq(3)
      end
    end
  end
end
