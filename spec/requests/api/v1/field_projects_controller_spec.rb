# frozen_string_literal: true

require 'rails_helper'

describe 'FieldProjecs' do
  describe 'show' do
    let(:target_id) { 10 }

    it 'returns OK' do
      create(:field_project, id: target_id)
      get api_v1_field_project_path(id: target_id)

      expect(response.status).to eq(200)
    end

    context 'when project does not have samples' do
      it 'returns empty array for samples' do
        create(:field_project, id: target_id)

        get api_v1_field_project_path(id: target_id)
        data = JSON.parse(response.body)

        expect(data['samples']['data']).to eq([])
      end

      it 'returns empty array for asvs' do
        create(:field_project, id: target_id)

        get api_v1_field_project_path(id: target_id)
        data = JSON.parse(response.body)

        expect(data['asvs_count']).to eq([])
      end
    end

    context 'when project has approved samples' do
      it 'returns the associated samples' do
        project = create(:field_project, id: target_id)
        sample1 = create(:sample, :approved, field_project: project)
        sample2 = create(:sample, :approved, field_project: project)

        get api_v1_field_project_path(id: target_id)
        data = JSON.parse(response.body)

        expect(data['samples']['data'].length).to eq(2)

        ids = data['samples']['data'].map { |s| s['id'].to_i }
        expect(ids).to match_array([sample1.id, sample2.id])
      end

      it 'returns empty array for asvs' do
        project = create(:field_project, id: target_id)
        create(:sample, :approved, field_project: project)

        get api_v1_field_project_path(id: target_id)
        data = JSON.parse(response.body)

        expect(data['asvs_count']).to eq([])
      end
    end

    context 'when project has samples with results' do
      it 'returns the associated samples' do
        project = create(:field_project, id: target_id)
        sample1 = create(:sample, :results_completed, field_project: project)
        sample2 = create(:sample, :results_completed, field_project: project)

        get api_v1_field_project_path(id: target_id)
        data = JSON.parse(response.body)

        expect(data['samples']['data'].length).to eq(2)

        ids = data['samples']['data'].map { |s| s['id'].to_i }
        expect(ids).to match_array([sample1.id, sample2.id])
      end

      it 'returns the number of associated asvs for asv count' do
        project = create(:field_project, id: target_id)
        sample = create(:sample, :results_completed, field_project: project)
        extraction = create(:extraction, sample: sample)
        create(:asv, sample: sample, extraction: extraction)
        create(:asv, sample: sample, extraction: extraction)
        create(:asv, sample: sample, extraction: extraction)

        get api_v1_field_project_path(id: target_id)
        data = JSON.parse(response.body)

        expect(data['asvs_count'].length).to eq(1)
        expect(data['asvs_count'].first['count']).to eq(3)
      end
    end

    it 'ignores samples from other projects' do
      create(:field_project, id: target_id)
      other_project = create(:field_project, id: 20)
      create(:sample, :approved, field_project: other_project)

      get api_v1_field_project_path(id: target_id)
      data = JSON.parse(response.body)

      expect(data['samples']['data']).to eq([])
    end

    context 'keyword query param' do
      let(:project) { create(:field_project, id: target_id) }

      before(:each) do
        create(:sample, :approved, id: 1, field_project: project)
        create(:sample, :approved, id: 2, field_project: project)

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
        get api_v1_field_project_path(id: target_id, keyword: 'match')
        data = JSON.parse(response.body)['samples']['data']

        expect(data.length).to eq(2)

        ids = data.map { |i| i['attributes']['id'] }
        expect(ids).to match_array([1, 2])
      end
    end

    context 'substrate query param' do
      let(:project) { create(:field_project, id: target_id) }
      before(:each) do
        create(:sample, :approved, substrate_cd: :soil, field_project: project)
        create(:sample, :approved, substrate_cd: :bad, field_project: project)
        create(:sample, :approved, substrate_cd: :sediment,
                                   field_project: project)
      end

      it 'returns samples when there is one substrate' do
        get api_v1_field_project_path(id: target_id, substrate: :soil)
        data = JSON.parse(response.body)['samples']['data']

        expect(data.length).to eq(1)

        substrate = data.map { |i| i['attributes']['substrate'] }
        expect(substrate).to match_array(['soil'])
      end

      it 'returns samples when there are multiple substrate' do
        get api_v1_field_project_path(id: target_id, substrate: 'soil|sediment')
        data = JSON.parse(response.body)['samples']['data']

        expect(data.length).to eq(2)

        substrate = data.map { |i| i['attributes']['substrate'] }
        expect(substrate).to match_array(%w[sediment soil])
      end
    end

    context 'status query param' do
      let(:project) { create(:field_project, id: target_id) }

      before(:each) do
        create(:sample, :approved, field_project: project)
        create(:sample, :results_completed, field_project: project)
      end

      it 'returns samples when there is one status' do
        get api_v1_field_project_path(id: target_id, status: :results_completed)
        json = JSON.parse(response.body)

        expect(json['samples']['data'].length).to eq(1)
      end

      it 'ignores multiple status' do
        get api_v1_field_project_path(id: target_id,
                                      status: 'approved|results_completed')
        json = JSON.parse(response.body)

        expect(json['samples']['data'].length).to eq(0)
      end
    end

    context 'primer query param' do
      let(:project) { create(:field_project, id: target_id) }

      before(:each) do
        create(:sample, :approved, primers: ['12S'], field_project: project)
        create(:sample, :approved, primers: ['18s'], field_project: project)
        create(:sample, :approved, primers: ['bad'], field_project: project)
        create(:primer, name: '12S')
        create(:primer, name: '18s')
      end

      it 'returns samples when there is one primer' do
        get api_v1_field_project_path(id: target_id, primer: '12S')
        data = JSON.parse(response.body)['samples']['data']

        expect(data.length).to eq(1)

        primer = data.map { |i| i['attributes']['primers'] }
        expect(primer).to match_array([['12S']])
      end

      it 'returns samples when there are multiple primer' do
        get api_v1_field_project_path(id: target_id, primer: '12S|18s')
        data = JSON.parse(response.body)['samples']['data']

        expect(data.length).to eq(2)

        primer = data.map { |i| i['attributes']['primers'] }
        expect(primer).to match_array([['12S'], ['18s']])
      end

      it 'ignores invalid primers' do
        get api_v1_field_project_path(id: target_id, primer: 'bad')
        data = JSON.parse(response.body)['samples']['data']

        expect(data.length).to eq(0)
      end
    end

    context 'multiple query params' do
      let(:project) { create(:field_project, id: target_id) }

      before(:each) do
        create(:sample, :results_completed, id: 1, substrate_cd: :soil,
                                            primers: ['12S'],
                                            field_project: project)
        create(:sample, :results_completed, id: 2, substrate_cd: :foo,
                                            primers: ['12S'],
                                            field_project: project)
        create(:sample, :geo, id: 3, substrate_cd: :soil,
                              status_cd: :foo, primers: ['12S'],
                              field_project: project)
        create(:sample, :results_completed, id: 4, substrate_cd: :soil,
                                            primers: ['foo'],
                                            field_project: project)
        create(:sample, :approved, id: 5, substrate_cd: :soil,
                                   primers: ['12S'], field_project: project)
        create(:sample, :approved, id: 6)
        create(:primer, name: '12S')
      end

      it 'returns samples that match substrate & status' do
        get api_v1_field_project_path(id: target_id, substrate: 'soil',
                                      status: 'results_completed')
        data = JSON.parse(response.body)['samples']['data']

        expect(data.length).to eq(2)

        ids = data.map { |i| i['attributes']['id'] }
        expect(ids).to match_array([1, 4])
      end

      it 'returns samples that match substrate & primer' do
        get api_v1_field_project_path(id: target_id, substrate: 'soil',
                                      primer: '12S')
        data = JSON.parse(response.body)['samples']['data']

        expect(data.length).to eq(2)

        ids = data.map { |i| i['attributes']['id'] }
        expect(ids).to match_array([1, 5])
      end

      it 'returns samples that match all the query params' do
        get api_v1_field_project_path(id: target_id, substrate: 'soil',
                                      status: 'results_completed',
                                      primer: '12S')
        data = JSON.parse(response.body)['samples']['data']

        expect(data.length).to eq(1)

        ids = data.map { |i| i['attributes']['id'] }
        expect(ids).to match_array([1])
      end
    end
  end
end
