# frozen_string_literal: true

require 'rails_helper'

describe 'Taxa' do
  before do
    stub_const('Website::DEFAULT_SITE', create(:website, name: 'CALeDNA'))
  end

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

    def create_occurence(taxon, substrate: :soil, primer: create(:primer),
                         status: :results_completed,
                         research_project: create(:research_project))

      sample = create(:sample, status: status, substrate_cd: substrate)
      create(:asv, sample: sample, taxon_id: taxon.taxon_id,
                   research_project: research_project, primer: primer)
      create(:sample_primer, primer: primer, sample: sample,
                             research_project: research_project)
      sample
    end

    def parse_response(response)
      samples = JSON.parse(response.body)['samples']['data']
      base_samples = JSON.parse(response.body)['base_samples']['data']

      [samples, base_samples]
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
      samples, base_samples = parse_response(response)

      expect(samples.length).to eq(1)
      expect(base_samples.length).to eq(1)
    end

    it 'returns samples whose ids contain a given taxon' do
      taxon = create(:ncbi_node, ids: [1, target_id, 3], id: 3)
      create_occurence(taxon)

      get api_v1_taxon_path(id: target_id)
      samples, base_samples = parse_response(response)

      expect(samples.length).to eq(1)
      expect(base_samples.length).to eq(1)
    end

    it 'returns unique samples for a given taxon' do
      taxon1 = create(:ncbi_node, ids: [1, target_id, 3], id: 3)
      taxon2 = create(:ncbi_node, ids: [1, target_id], id: target_id)

      sample1 = create(:sample, :results_completed)
      create(:asv, sample: sample1, taxon_id: taxon1.taxon_id)
      create(:asv, sample: sample1, taxon_id: taxon2.taxon_id)

      get api_v1_taxon_path(id: target_id)
      samples, base_samples = parse_response(response)

      expect(samples.length).to eq(1)
      expect(base_samples.length).to eq(1)
    end

    it 'ignores samples that contain other taxa' do
      taxon = create(:ncbi_node, ids: [4], id: 4)
      create_occurence(taxon)

      get api_v1_taxon_path(id: target_id)
      samples, base_samples = parse_response(response)

      expect(samples.length).to eq(0)
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
      samples, base_samples = parse_response(response)

      expect(samples.length).to eq(2)
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
        samples, base_samples = parse_response(response)

        expect(samples.length).to eq(2)
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
        samples, base_samples = parse_response(response)

        expect(samples.length).to eq(1)
        expect(base_samples.length).to eq(1)

        substrate = samples.map { |i| i['attributes']['substrate'] }
        expect(substrate).to eq(['soil'])
      end

      it 'returns samples when there is multiple substrate' do
        get api_v1_taxon_path(id: target_id, substrate: 'soil|sediment')
        samples, base_samples = parse_response(response)

        expect(samples.length).to eq(2)
        expect(base_samples.length).to eq(2)

        substrate = samples.map { |i| i['attributes']['substrate'] }
        expect(substrate).to match_array(%w[sediment soil])
      end
    end

    context 'status query param' do
      before(:each) do
        taxon = create(:ncbi_node, ids: [1, target_id, 3], id: 3)
        project = create(:research_project, slug: target_id)
        create_occurence(taxon, status: :results_completed,
                                research_project: project)
        create_occurence(taxon, status: :approved, research_project: project)
      end

      it 'ignores status params and only returns completed samples ' do
        get api_v1_taxon_path(id: target_id, status: 'foo')
        samples, base_samples = parse_response(response)

        expect(samples.length).to eq(1)
        expect(base_samples.length).to eq(1)

        substrate = samples.map { |i| i['attributes']['status'] }
        expect(substrate).to match_array(%w[results_completed])
      end
    end

    describe 'primer query param' do
      let(:primer1_id) { 10 }
      let(:primer2_id) { 20 }
      let(:primer1_name) { 'primer1' }
      let(:primer2_name) { 'primer2' }

      def create_samples
        taxon = create(:ncbi_node, ids: [1, target_id, 3], id: 3)
        primer1 = create(:primer, id: primer1_id, name: primer1_name)
        primer2 = create(:primer, id: primer2_id, name: primer2_name)
        create_occurence(taxon, primer: primer1)
        create_occurence(taxon, primer: primer2)
        create_occurence(taxon, primer: create(:primer, id: 30))
      end

      it 'returns samples when there is one primer' do
        create_samples

        get api_v1_taxon_path(id: target_id, primer: primer1_id)
        samples, base_samples = parse_response(response)

        expect(samples.length).to eq(1)
        expect(base_samples.length).to eq(1)

        primer_ids = samples.map { |i| i['attributes']['primer_ids'] }
        expect(primer_ids).to match_array([[primer1_id]])

        primer_names = samples.map { |i| i['attributes']['primer_names'] }
        expect(primer_names).to match_array([[primer1_name]])
      end

      it 'returns samples when there is multiple primers' do
        create_samples

        get api_v1_taxon_path(id: target_id,
                              primer: "#{primer1_id}|#{primer2_id}")
        samples, base_samples = parse_response(response)

        expect(samples.length).to eq(2)
        expect(base_samples.length).to eq(2)

        primer_ids = samples.map { |i| i['attributes']['primer_ids'] }
        expect(primer_ids).to match_array([[primer1_id], [primer2_id]])

        primer_names = samples.map { |i| i['attributes']['primer_names'] }
        expect(primer_names).to match_array([[primer1_name], [primer2_name]])
      end

      it 'ignores invalid primers' do
        create_samples

        get api_v1_taxon_path(id: target_id, primer: 999)
        data = JSON.parse(response.body)['samples']['data']

        expect(data.length).to eq(0)
      end

      it 'only includes one instance of a sample' do
        taxon = create(:ncbi_node, ids: [1, target_id, 3], id: 3)
        primer1 = create(:primer, id: primer1_id, name: 'primer1')
        primer2 = create(:primer, id: primer2_id, name: 'primer2')
        sample = create(:sample, :results_completed)

        research_project = create(:research_project)
        create(:asv, sample: sample, taxon_id: taxon.taxon_id, primer: primer1,
                     research_project: research_project)
        create(:asv, sample: sample, taxon_id: taxon.taxon_id, primer: primer2,
                     research_project: research_project)
        create(:sample_primer, primer: primer1, sample: sample,
                               research_project: research_project)
        create(:sample_primer, primer: primer2, sample: sample,
                               research_project: research_project)

        get api_v1_taxon_path(id: target_id,
                              primer: "#{primer1_id}|#{primer2_id}")
        samples, base_samples = parse_response(response)

        expect(samples.length).to eq(1)
        expect(base_samples.length).to eq(1)

        primer_ids = samples.map { |i| i['attributes']['primer_ids'] }
        expect(primer_ids).to match_array([[primer1_id, primer2_id]])

        primer_names = samples.map { |i| i['attributes']['primer_names'] }
        expect(primer_names).to match_array([[primer1_name, primer2_name]])
      end
    end
  end
end
