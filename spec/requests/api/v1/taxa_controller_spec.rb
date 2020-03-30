# frozen_string_literal: true

require 'rails_helper'

describe 'Taxa' do
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
    let(:target_id) { 10 }

    def create_occurence(taxon, substrate: :soil, primers: '12S',
                         status: :results_completed)

      sample = create(:sample, status: status, substrate_cd: substrate,
                               primers: primers.split('|'))
      create(:asv, sample: sample, taxon_id: taxon.taxon_id)
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

    it 'returns unique samples for a given taxon' do
      taxon1 = create(:ncbi_node, ids: [1, target_id, 3], id: 3)
      taxon2 = create(:ncbi_node, ids: [1, target_id], id: target_id)

      sample1 = create(:sample, :results_completed)
      create(:asv, sample: sample1, taxon_id: taxon1.taxon_id)
      create(:asv, sample: sample1, taxon_id: taxon2.taxon_id)

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

    context 'keyword query param' do
      before(:each) do
        ActiveRecord::Base.connection.execute(
          <<-SQL
          INSERT INTO "pg_search_documents"
          ("content", "searchable_type", "searchable_id", "created_at",
          "updated_at")
          VALUES('match', 'Sample', 1, '2018-10-20', '2018-10-20');
          SQL
        )
      end

      it 'does not affect the associated samples' do
        taxon = create(:ncbi_node, ids: [1, target_id], id: target_id)
        sample1 = create_occurence(taxon)
        sample2 = create_occurence(taxon)

        get api_v1_taxon_path(id: target_id, keyword: 'match')
        samples, asvs_count, base_samples = parse_response(response)

        expect(samples.length).to eq(2)
        expect(asvs_count.length).to eq(2)
        expect(base_samples.length).to eq(2)

        sample_ids = samples.map { |i| i['attributes']['id'] }
        expect(sample_ids).to eq([sample1.id, sample2.id])
      end
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
    end

    context 'status query param' do
      let(:project) { create(:research_project, slug: target_id) }

      before(:each) do
        taxon = create(:ncbi_node, ids: [1, target_id, 3], id: 3)
        create_occurence(taxon, status: :results_completed)
        create_occurence(taxon, status: :approved)
      end

      it 'ignores status params and only returns completed samples ' do
        get api_v1_taxon_path(id: target_id, status: 'foo')
        samples, asvs_count, base_samples = parse_response(response)

        expect(samples.length).to eq(1)
        expect(asvs_count.length).to eq(2)
        expect(base_samples.length).to eq(1)

        substrate = samples.map { |i| i['attributes']['status'] }
        expect(substrate).to match_array(%w[results_completed])
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

      it 'ignores invalid primers' do
        get api_v1_field_project_path(id: target_id, primer: 'bad')
        data = JSON.parse(response.body)['samples']['data']

        expect(data.length).to eq(0)
      end
    end
  end
end
