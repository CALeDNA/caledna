# frozen_string_literal: true

require 'rails_helper'

describe 'ResearchProjects' do
  describe 'show' do
    let(:target_id) { 'project-slug' }
    def create_project_samples(project, sample_id: rand(1...100_000_000),
                               substrate: :soil, status: :results_completed,
                               primer: create(:primer))
      sample = create(:sample, id: sample_id, substrate: substrate,
                               status: status)
      create(:asv, sample: sample)
      create(:asv, sample: sample)
      create(:asv, sample: sample)
      create(:research_project_source, sourceable: sample,
                                       research_project_id: project.id)
      create(:sample_primer, primer: primer, sample: sample,
                             research_project_id: project.id)
    end

    it 'returns OK' do
      create(:research_project, slug: target_id)
      get api_v1_research_project_path(id: target_id)

      expect(response.status).to eq(200)
    end

    context 'when project does not have samples' do
      it 'returns empty array for samples' do
        create(:research_project, slug: target_id)

        get api_v1_research_project_path(id: target_id)
        data = JSON.parse(response.body)

        expect(data['samples']['data']).to eq([])
      end

      it 'returns empty array for asvs' do
        create(:research_project, slug: target_id)

        get api_v1_research_project_path(id: target_id)
        data = JSON.parse(response.body)

        expect(data['asvs_count']).to eq([])
      end
    end

    context 'when project has samples with results' do
      it 'returns the associated samples' do
        project = create(:research_project, slug: target_id)
        create_project_samples(project, sample_id: 1)
        create_project_samples(project, sample_id: 2)

        get api_v1_research_project_path(id: target_id)
        data = JSON.parse(response.body)

        expect(data['samples']['data'].length).to eq(2)

        ids = data['samples']['data'].map { |s| s['id'].to_i }
        expect(ids).to match_array([1, 2])
      end

      it 'returns the number of associated asvs for asv count' do
        project = create(:research_project, slug: target_id)
        create_project_samples(project, sample_id: 1)
        create_project_samples(project, sample_id: 2)

        get api_v1_research_project_path(id: target_id)
        data = JSON.parse(response.body)

        expect(data['asvs_count'].length).to eq(2)

        expected = [
          { 'sample_id' => 1, 'count' => 3 }, { 'sample_id' => 2, 'count' => 3 }
        ]
        expect(data['asvs_count']).to match_array(expected)
      end
    end

    it 'ignores samples from other projects' do
      create(:research_project, slug: target_id)
      other_project = create(:research_project, slug: 'other')
      create_project_samples(other_project)

      get api_v1_research_project_path(id: target_id)
      data = JSON.parse(response.body)

      expect(data['samples']['data']).to eq([])
    end

    context 'keyword query param' do
      let(:project) { create(:research_project, slug: target_id) }

      before(:each) do
        create_project_samples(project, sample_id: 1)
        create_project_samples(project, sample_id: 2)

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
        get api_v1_research_project_path(id: target_id, keyword: 'match')
        data = JSON.parse(response.body)['samples']['data']

        expect(data.length).to eq(2)

        ids = data.map { |i| i['attributes']['id'] }
        expect(ids).to match_array([1, 2])
      end
    end

    context 'substrate query param' do
      let(:project) { create(:research_project, slug: target_id) }

      before(:each) do
        create_project_samples(project, substrate: :soil)
        create_project_samples(project, substrate: :sediment)
      end

      it 'returns samples when there is one substrate' do
        get api_v1_research_project_path(id: target_id, substrate: :soil)
        data = JSON.parse(response.body)['samples']['data']

        expect(data.length).to eq(1)

        substrate = data.map { |i| i['attributes']['substrate'] }
        expect(substrate).to match_array(['soil'])
      end

      it 'returns samples when there are multiple substrate' do
        get api_v1_research_project_path(id: target_id,
                                         substrate: 'soil|sediment')
        data = JSON.parse(response.body)['samples']['data']

        expect(data.length).to eq(2)

        substrate = data.map { |i| i['attributes']['substrate'] }
        expect(substrate).to match_array(%w[sediment soil])
      end
    end

    context 'status query param' do
      let(:project) { create(:research_project, slug: target_id) }

      before(:each) do
        create_project_samples(project, sample_id: 1, status: :approved)
        create_project_samples(project, sample_id: 2,
                                        status: :results_completed)
      end

      it 'ignores status params and only returns completed samples ' do
        get api_v1_research_project_path(id: target_id, status: 'foo')
        json = JSON.parse(response.body)

        expect(json['samples']['data'].length).to eq(1)
        expect(json['samples']['data'].first['id'].to_i).to eq(2)
      end
    end

    context 'primer query param' do
      let(:primer1_id) { 10 }
      let(:primer2_id) { 20 }
      let(:project) { create(:research_project, slug: target_id) }
      let(:primer1) { create(:primer, id: primer1_id) }
      let(:primer2) { create(:primer, id: primer2_id) }

      it 'returns samples when there is one primer' do
        create_project_samples(project, primer: primer1)
        create_project_samples(project, primer: primer2)

        get api_v1_research_project_path(id: target_id, primer: '10')
        data = JSON.parse(response.body)['samples']['data']

        expect(data.length).to eq(1)

        primer = data.map { |i| i['attributes']['primers'] }
        expect(primer).to match_array([[primer1_id]])
      end

      it 'returns samples when there are multiple primer' do
        create_project_samples(project, primer: primer1)
        create_project_samples(project, primer: primer2)

        get api_v1_research_project_path(id: target_id,
                                         primer: "#{primer1_id}|#{primer2_id}")
        data = JSON.parse(response.body)['samples']['data']

        expect(data.length).to eq(2)

        primer = data.map { |i| i['attributes']['primers'] }
        expect(primer).to match_array([[primer1_id], [primer2_id]])
      end

      it 'ignores invalid primers' do
        create_project_samples(project, primer: primer1)
        create_project_samples(project, primer: primer2)

        get api_v1_research_project_path(id: target_id, primer: 999)
        data = JSON.parse(response.body)['samples']['data']

        expect(data.length).to eq(0)
      end

      it 'ignores primers from other research projects' do
        sample = create(:sample, :results_completed, id: 1)
        create(:research_project, slug: 'proj1', id: 100)
        create(:research_project, slug: 'proj2', id: 200)
        create(:research_project_source, sourceable: sample,
                                         research_project_id: 100)
        create(:sample_primer, primer: primer1, sample: sample,
                               research_project_id: 100)
        create(:research_project_source, sourceable: sample,
                                         research_project_id: 200)
        create(:sample_primer, primer: primer2, sample: sample,
                               research_project_id: 200)

        get api_v1_research_project_path(id: 'proj1', primer: primer1_id)
        data = JSON.parse(response.body)['samples']['data']

        expect(data.length).to eq(1)

        primer = data.map { |i| i['attributes']['primers'] }
        expect(primer).to match_array([[primer1_id]])
      end

      it 'only includes one instance of a sample' do
        sample = create(:sample, :results_completed, id: 1)
        create(:research_project, slug: 'proj1', id: 100)
        create(:research_project_source, sourceable: sample,
                                         research_project_id: 100)
        create(:sample_primer, primer: primer1, sample: sample,
                               research_project_id: 100)
        create(:sample_primer, primer: primer2, sample: sample,
                               research_project_id: 100)

        get api_v1_research_project_path(id: 'proj1',
                                         primer: "#{primer1_id}|#{primer2_id}")
        data = JSON.parse(response.body)['samples']['data']

        expect(data.length).to eq(1)

        primer = data.map { |i| i['attributes']['primers'] }
        expect(primer).to match_array([[primer1_id, primer2_id]])
      end
    end

    context 'multiple query params' do
      let(:primer1_id) { 10 }
      let(:primer2_id) { 20 }
      let(:project) { create(:research_project, slug: target_id) }

      before(:each) do
        p1 = create(:primer, id: primer1_id)
        p2 = create(:primer, id: primer2_id)
        create_project_samples(project, sample_id: 1, substrate: :soil,
                                        primer: p1)
        create_project_samples(project, sample_id: 2, substrate: :foo,
                                        primer: p1)
        create_project_samples(project, sample_id: 3, substrate: :soil,
                                        primer: p2)
        create(:sample, :approved, id: 5)
      end

      it 'returns samples that match substrate & primer' do
        get api_v1_research_project_path(id: target_id, substrate: 'soil',
                                         primer: primer1_id)
        data = JSON.parse(response.body)['samples']['data']

        expect(data.length).to eq(1)

        ids = data.map { |i| i['attributes']['id'] }
        expect(ids).to match_array([1])
      end
    end
  end
end
