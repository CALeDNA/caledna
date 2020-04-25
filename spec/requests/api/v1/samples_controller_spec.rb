# frozen_string_literal: true

require 'rails_helper'

describe 'Samples' do
  describe 'index' do
    it 'returns OK' do
      get api_v1_samples_path

      expect(response.status).to eq(200)
    end

    it 'returns all valid samples' do
      create(:sample, :approved)
      create(:sample, :results_completed)
      get api_v1_samples_path

      json = JSON.parse(response.body)

      expect(json['samples']['data'].length).to eq(2)
    end

    it 'ignores invalid samples' do
      create_list(:sample, 3)
      get api_v1_samples_path

      json = JSON.parse(response.body)

      expect(json['samples']['data'].length).to eq(0)
    end

    context 'keyword query param' do
      before(:each) do
        create(:sample, :approved, id: 1)
        create(:sample, :approved, id: 2)
        create(:sample, :results_completed, id: 3)

        ActiveRecord::Base.connection.execute(
          <<-SQL
          INSERT INTO "pg_search_documents"
          ("content", "searchable_type", "searchable_id", "created_at",
          "updated_at")
          VALUES('match', 'Sample', 1, '2018-10-20', '2018-10-20');
          INSERT INTO "pg_search_documents"
          ("content", "searchable_type", "searchable_id", "created_at",
          "updated_at")
          VALUES('match', 'Sample', 2, '2018-10-20', '2018-10-20');
          SQL
        )
      end

      it 'returns samples that contain the keyword' do
        get api_v1_samples_path(keyword: 'match')
        data = JSON.parse(response.body)['samples']['data']

        expect(data.length).to eq(2)

        ids = data.map { |i| i['attributes']['id'] }
        expect(ids).to eq([1, 2])
      end

      it 'returns empty array if no samples contain the keyword' do
        get api_v1_samples_path(keyword: 'random')
        data = JSON.parse(response.body)['samples']['data']

        expect(data).to eq([])
      end
    end

    context 'substrate query param' do
      before(:each) do
        create(:sample, :approved, substrate_cd: :soil)
        create(:sample, :approved, substrate_cd: :bad)
        create(:sample, :results_completed, substrate_cd: :sediment)
      end

      it 'returns samples when there is one substrate' do
        get api_v1_samples_path(substrate: :soil)
        data = JSON.parse(response.body)['samples']['data']

        expect(data.length).to eq(1)

        substrate = data.map { |i| i['attributes']['substrate'] }
        expect(substrate).to eq(['soil'])
      end

      it 'returns samples when there are multiple substrate' do
        get api_v1_samples_path(substrate: 'soil|sediment')
        data = JSON.parse(response.body)['samples']['data']

        expect(data.length).to eq(2)

        substrate = data.map { |i| i['attributes']['substrate'] }
        expect(substrate).to match_array(%w[sediment soil])
      end
    end

    context 'status query param' do
      before(:each) do
        create(:sample, :approved, status_cd: :approved)
        create(:sample, :approved, status_cd: :results_completed)
      end

      it 'returns samples when there is one status' do
        get api_v1_samples_path(status: :results_completed)
        json = JSON.parse(response.body)

        expect(json['samples']['data'].length).to eq(1)
      end

      it 'ignores multiple status' do
        get api_v1_samples_path(status: 'approved|results_completed')
        json = JSON.parse(response.body)

        expect(json['samples']['data'].length).to eq(0)
      end
    end

    context 'primer query param' do
      let(:primer1_id) { 10 }
      let(:primer2_id) { 20 }

      before(:each) do
        s1 = create(:sample, :approved)
        s2 = create(:sample, :results_completed)
        p1 = create(:primer, name: 'primer1', id: primer1_id)
        p2 = create(:primer, name: 'primer2', id: primer2_id)

        rproj1 = create(:research_project)
        rproj2 = create(:research_project)
        create(:sample_primer, sample: s1, primer: p1, research_project: rproj1)
        create(:sample_primer, sample: s1, primer: p1, research_project: rproj2)
        create(:sample_primer, sample: s2, primer: p2, research_project: rproj1)
      end

      it 'returns samples when there is one primer' do
        get api_v1_samples_path(primer: primer1_id)
        data = JSON.parse(response.body)['samples']['data']

        expect(data.length).to eq(1)

        primer = data.flat_map { |i| i['attributes']['primers'] }
        expect(primer).to match_array(
          [
            { 'id' => primer1_id, 'name' => 'primer1' }
          ]
        )
      end

      it 'returns samples when there are multiple primer' do
        get api_v1_samples_path(primer: "#{primer1_id}|#{primer2_id}")
        data = JSON.parse(response.body)['samples']['data']

        expect(data.length).to eq(2)

        primer = data.flat_map { |i| i['attributes']['primers'] }
        expect(primer).to match_array(
          [
            { 'id' => primer1_id, 'name' => 'primer1' },
            { 'id' => primer2_id, 'name' => 'primer2' }
          ]
        )
      end

      it 'ignores invalid primers' do
        get api_v1_samples_path(primer: 999)
        data = JSON.parse(response.body)['samples']['data']

        expect(data.length).to eq(0)
      end
    end

    context 'multiple query params' do
      let(:primer1_id) { 10 }
      let(:primer2_id) { 20 }

      before(:each) do
        s1 = create(:sample, :results_completed, id: 1, substrate_cd: :soil)
        s2 = create(:sample, :results_completed, id: 2, substrate_cd: :soil)
        s3 = create(:sample, :results_completed, id: 3, substrate_cd: :foo)
        s4 = create(:sample, :geo, id: 4, substrate_cd: :soil,
                                   status_cd: :rejected)
        create(:sample, :results_completed, id: 5, substrate_cd: :soil)
        s6 = create(:sample, :approved, id: 6, substrate_cd: :soil)
        create(:sample, :approved, id: 7)
        p1 = create(:primer, name: '12S', id: primer1_id)

        proj1 = create(:research_project)
        proj2 = create(:research_project)
        create(:sample_primer, sample: s1, primer: p1, research_project: proj1)
        create(:sample_primer, sample: s1, primer: p1, research_project: proj2)
        create(:sample_primer, sample: s2, primer: p1, research_project: proj1)
        create(:sample_primer, sample: s3, primer: p1, research_project: proj1)
        create(:sample_primer, sample: s4, primer: p1, research_project: proj1)
        create(:sample_primer, sample: s6, primer: p1, research_project: proj1)

        ActiveRecord::Base.connection.execute(
          <<-SQL
          INSERT INTO "pg_search_documents"
          ("content", "searchable_type", "searchable_id", "created_at",
          "updated_at")
          VALUES('match', 'Sample', 1, '2018-10-20', '2018-10-20');
          INSERT INTO "pg_search_documents"
          ("content", "searchable_type", "searchable_id", "created_at",
          "updated_at")
          VALUES('match', 'Sample', 3, '2018-10-20', '2018-10-20');
          INSERT INTO "pg_search_documents"
          ("content", "searchable_type", "searchable_id", "created_at",
          "updated_at")
          VALUES('match', 'Sample', 6, '2018-10-20', '2018-10-20');
          SQL
        )
      end

      it 'returns samples that match substrate & status' do
        get api_v1_samples_path(substrate: 'soil',
                                status: 'results_completed')
        data = JSON.parse(response.body)['samples']['data']

        expect(data.length).to eq(3)

        ids = data.map { |i| i['attributes']['id'] }
        expect(ids).to eq([1, 2, 5])
      end

      it 'returns samples that match substrate & primer' do
        get api_v1_samples_path(substrate: 'soil',
                                primer: primer1_id)
        data = JSON.parse(response.body)['samples']['data']

        expect(data.length).to eq(3)

        ids = data.map { |i| i['attributes']['id'] }
        expect(ids).to eq([1, 2, 6])
      end

      it 'returns samples that match substrate & keyword' do
        get api_v1_samples_path(substrate: 'soil',
                                keyword: 'match')
        data = JSON.parse(response.body)['samples']['data']

        expect(data.length).to eq(2)

        ids = data.map { |i| i['attributes']['id'] }
        expect(ids).to eq([1, 6])
      end

      it 'returns samples that match all the query params' do
        get api_v1_samples_path(substrate: 'soil',
                                status: 'results_completed',
                                keyword: 'match',
                                primer: primer1_id)
        data = JSON.parse(response.body)['samples']['data']

        expect(data.length).to eq(1)

        ids = data.map { |i| i['attributes']['id'] }
        expect(ids).to eq([1])
      end
    end
  end

  describe 'show' do
    it 'returns OK when sample is approved' do
      sample = create(:sample, :approved)
      get api_v1_sample_path(id: sample.id)

      expect(response.status).to eq(200)
    end

    context 'when sample is approved' do
      it 'returns the sample data for the given sample' do
        sample = create(:sample, :approved)

        get api_v1_sample_path(id: sample.id)
        data = JSON.parse(response.body)

        expect(data['sample']['data']['id'].to_i).to eq(sample.id)
      end

      it 'returns 0 for asc count' do
        sample = create(:sample, :approved)

        get api_v1_sample_path(id: sample.id)
        data = JSON.parse(response.body)

        expect(data['asvs_count'].first['count']).to eq(0)
      end
    end

    context 'when sample has results' do
      it 'returns the sample data for the given sample' do
        sample = create(:sample, :results_completed)

        get api_v1_sample_path(id: sample.id)
        data = JSON.parse(response.body)

        expect(data['sample']['data']['id'].to_i).to eq(sample.id)
      end

      it 'returns the number of associated asvs for asv count' do
        sample = create(:sample, :results_completed)
        create(:asv, sample: sample)
        create(:asv, sample: sample)
        create(:asv, sample: sample)

        get api_v1_sample_path(id: sample.id)
        data = JSON.parse(response.body)

        expect(data['asvs_count'].first['count']).to eq(3)
      end
    end

    it 'raises an error if sample is not approved' do
      sample = create(:sample, status_cd: :submitted, latitude: 1, longitude: 1)

      expect { get api_v1_sample_path(id: sample.id) }
        .to raise_error(ActiveRecord::RecordNotFound)
    end

    it 'raises an error if sample does not have coordinates' do
      sample = create(:sample, status_cd: :approved, latitude: nil,
                               longitude: nil)

      expect { get api_v1_sample_path(id: sample.id) }
        .to raise_error(ActiveRecord::RecordNotFound)
    end

    it 'raises an error for invalid id' do
      expect { get api_v1_sample_path(id: 1) }
        .to raise_error(ActiveRecord::RecordNotFound)
    end
  end
end
