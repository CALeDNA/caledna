# frozen_string_literal: true

require 'rails_helper'

describe 'Samples' do
  describe 'index' do
    it 'returns OK' do
      get api_v1_samples_path

      expect(response.status).to eq(200)
    end

    it 'returns all valid samples' do
      create_list(:sample, 3, :valid)
      get api_v1_samples_path

      json = JSON.parse(response.body)

      expect(json['samples']['data'].length).to eq(3)
    end

    it 'ignores invalid samples' do
      create_list(:sample, 3)
      get api_v1_samples_path

      json = JSON.parse(response.body)

      expect(json['samples']['data'].length).to eq(0)
    end

    describe 'keyword query param' do
      before(:each) do
        create(:sample, :valid, id: 1)
        create(:sample, :valid, id: 2)
        create(:sample, :valid, id: 3)

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

    describe 'substrate query param' do
      before(:each) do
        create(:sample, :valid, substrate_cd: :soil)
        create(:sample, :valid, substrate_cd: :bad)
        create(:sample, :valid, substrate_cd: :sediment)
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

    describe 'status query param' do
      before(:each) do
        create(:sample, :valid, status_cd: :approved)
        create(:sample, :valid, status_cd: :results_completed)
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

    describe 'primer query param' do
      before(:each) do
        create(:sample, :valid, primers: ['12S'])
        create(:sample, :valid, primers: ['18s'])
        create(:sample, :valid, primers: ['bad'])
        create(:primer, name: '12S')
        create(:primer, name: '18s')
      end

      it 'returns samples when there is one primer' do
        get api_v1_samples_path(primer: '12S')
        data = JSON.parse(response.body)['samples']['data']

        expect(data.length).to eq(1)

        primer = data.map { |i| i['attributes']['primers'] }
        expect(primer).to eq([['12S']])
      end

      it 'returns samples when there are multiple primer' do
        get api_v1_samples_path(primer: '12S|18s')
        data = JSON.parse(response.body)['samples']['data']

        expect(data.length).to eq(2)

        primer = data.map { |i| i['attributes']['primers'] }
        expect(primer).to match_array([['12S'], ['18s']])
      end
    end

    describe 'multiple query params' do
      before(:each) do
        create(:sample, :valid, id: 1, substrate_cd: :soil,
                                status_cd: :results_completed, primers: ['12S'])
        create(:sample, :valid, id: 2, substrate_cd: :soil,
                                status_cd: :results_completed, primers: ['12S'])
        create(:sample, :valid, id: 3, substrate_cd: :foo,
                                status_cd: :results_completed, primers: ['12S'])
        create(:sample, :valid, id: 4, substrate_cd: :soil,
                                status_cd: :foo, primers: ['12S'])
        create(:sample, :valid, id: 5, substrate_cd: :soil,
                                status_cd: :results_completed, primers: ['foo'])
        create(:sample, :valid, id: 6)
        create(:primer, name: '12S')

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
          VALUES('match', 'Sample', 4, '2018-10-20', '2018-10-20');
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
                                primer: '12S')
        data = JSON.parse(response.body)['samples']['data']

        expect(data.length).to eq(3)

        ids = data.map { |i| i['attributes']['id'] }
        expect(ids).to eq([1, 2, 4])
      end

      it 'returns samples that match substrate & keyword' do
        get api_v1_samples_path(substrate: 'soil',
                                keyword: 'match')
        data = JSON.parse(response.body)['samples']['data']

        expect(data.length).to eq(2)

        ids = data.map { |i| i['attributes']['id'] }
        expect(ids).to eq([1, 4])
      end

      it 'returns samples that match all the query params' do
        get api_v1_samples_path(substrate: 'soil',
                                status: 'results_completed',
                                keyword: 'match',
                                primer: '12S')
        data = JSON.parse(response.body)['samples']['data']

        expect(data.length).to eq(1)

        ids = data.map { |i| i['attributes']['id'] }
        expect(ids).to eq([1])
      end
    end
  end

  describe 'show' do
    it 'returns OK when sample is valid' do
      sample = create(:sample, status_cd: :approved, latitude: 1, longitude: 1)
      get sample_path(id: sample.id)

      expect(response.status).to eq(200)
    end

    it 'raises an error if sample is not approved' do
      sample = create(:sample, status_cd: :submitted, latitude: 1, longitude: 1)

      expect { get sample_path(id: sample.id) }
        .to raise_error(ActiveRecord::RecordNotFound)
    end

    it 'raises an error if sample does not have coordinates' do
      sample = create(:sample, status_cd: :approved, latitude: nil,
                               longitude: nil)

      expect { get sample_path(id: sample.id) }
        .to raise_error(ActiveRecord::RecordNotFound)
    end

    it 'raises an error for invalid id' do
      expect { get sample_path(id: 1) }
        .to raise_error(ActiveRecord::RecordNotFound)
    end
  end
end
