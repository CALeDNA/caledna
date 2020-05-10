# frozen_string_literal: true

require 'rails_helper'

describe 'FieldProjecs' do
  before do
    stub_const('Website::DEFAULT_SITE', create(:website, name: 'CALeDNA'))
  end

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
      let(:primer1_id) { 10 }
      let(:primer2_id) { 20 }
      let(:primer1_name) { 'primer1' }
      let(:primer2_name) { 'primer2' }
      let(:primer1) { create(:primer, name: primer1_name, id: primer1_id) }
      let(:primer2) { create(:primer, name: primer2_name, id: primer2_id) }
      let(:project) { create(:field_project, id: target_id) }

      # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
      def create_samples
        s1 = create(:sample, :approved, field_project: project)
        s2 = create(:sample, :approved, field_project: project)
        p1 = primer1
        p2 = primer2
        rproj1 = create(:research_project)
        rproj2 = create(:research_project)

        create(:asv, sample: s1, research_project: rproj1, primer: p1)
        create(:sample_primer, sample: s1, primer: p1, research_project: rproj1)
        create(:asv, sample: s1, research_project: rproj2, primer: p1)
        create(:sample_primer, sample: s1, primer: p1, research_project: rproj2)

        create(:asv, sample: s2, research_project: rproj1, primer: p2)
        create(:sample_primer, sample: s2, primer: p2, research_project: rproj1)
      end
      # rubocop:enable Metrics/MethodLength, Metrics/AbcSize

      it 'returns samples when there is one primer' do
        create_samples

        get api_v1_field_project_path(id: target_id, primer: primer1_id)
        data = JSON.parse(response.body)['samples']['data']

        expect(data.length).to eq(1)

        primer_ids = data.map { |i| i['attributes']['primer_ids'] }
        expect(primer_ids).to match_array([[primer1_id]])

        primer_names = data.map { |i| i['attributes']['primer_names'] }
        expect(primer_names).to match_array([[primer1_name]])
      end

      it 'returns samples when there are multiple primer' do
        create_samples

        get api_v1_field_project_path(id: target_id,
                                      primer: "#{primer1_id}|#{primer2_id}")
        data = JSON.parse(response.body)['samples']['data']

        expect(data.length).to eq(2)

        primer_ids = data.map { |i| i['attributes']['primer_ids'] }
        expect(primer_ids)
          .to match_array([[primer1_id], [primer2_id]])

        primer_names = data.map { |i| i['attributes']['primer_names'] }
        expect(primer_names)
          .to match_array([[primer1_name], [primer2_name]])
      end

      it 'ignores invalid primers' do
        create_samples

        get api_v1_field_project_path(id: target_id, primer: 999)
        data = JSON.parse(response.body)['samples']['data']

        expect(data.length).to eq(0)
      end

      it 'only includes one instance of a sample' do
        sample = create(:sample, :approved, id: 1, field_project: project)
        rproj = create(:research_project, slug: 'proj1')
        create(:asv, sample: sample, primer: primer1, research_project: rproj)
        create(:sample_primer, primer: primer1, sample: sample,
                               research_project: rproj)
        create(:asv, sample: sample, primer: primer2, research_project: rproj)
        create(:sample_primer, primer: primer2, sample: sample,
                               research_project: rproj)

        get api_v1_field_project_path(id: target_id,
                                      primer: "#{primer1_id}|#{primer2_id}")
        data = JSON.parse(response.body)['samples']['data']

        expect(data.length).to eq(1)

        primer_ids = data.map { |i| i['attributes']['primer_ids'] }
        expect(primer_ids)
          .to match_array([[primer1_id, primer2_id]])

        primer_names = data.map { |i| i['attributes']['primer_names'] }
        expect(primer_names)
          .to match_array([[primer1_name, primer2_name]])
      end
    end

    context 'multiple query params' do
      let(:primer1_id) { 10 }
      let(:primer2_id) { 20 }
      let(:project) { create(:field_project, id: target_id) }

      before(:each) do
        s1 = create(:sample, :results_completed, id: 1, substrate_cd: :soil,
                                                 field_project: project)
        s2 = create(:sample, :results_completed, id: 2, substrate_cd: :foo,
                                                 field_project: project)
        s3 = create(:sample, :geo, id: 3, substrate_cd: :soil,
                                   status_cd: :foo, field_project: project)
        create(:sample, :results_completed, id: 4, substrate_cd: :soil,
                                            field_project: project)
        s5 = create(:sample, :approved, id: 5, substrate_cd: :soil,
                                        field_project: project)
        create(:sample, :approved, id: 6)
        p1 = create(:primer, name: '12S', id: primer1_id)
        rproj1 = create(:research_project)
        rproj2 = create(:research_project)
        create(:asv, sample: s1, primer: p1, research_project: rproj1)
        create(:sample_primer, sample: s1, primer: p1, research_project: rproj1)
        create(:asv, sample: s1, primer: p1, research_project: rproj2)
        create(:sample_primer, sample: s1, primer: p1, research_project: rproj2)
        create(:asv, sample: s2, primer: p1, research_project: rproj1)
        create(:sample_primer, sample: s2, primer: p1, research_project: rproj1)
        create(:asv, sample: s3, primer: p1, research_project: rproj1)
        create(:sample_primer, sample: s3, primer: p1, research_project: rproj1)
        create(:asv, sample: s5, primer: p1, research_project: rproj1)
        create(:sample_primer, sample: s5, primer: p1, research_project: rproj1)
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
                                      primer: primer1_id)
        data = JSON.parse(response.body)['samples']['data']

        expect(data.length).to eq(2)

        ids = data.map { |i| i['attributes']['id'] }
        expect(ids).to match_array([1, 5])
      end

      it 'returns samples that match all the query params' do
        get api_v1_field_project_path(id: target_id, substrate: 'soil',
                                      status: 'results_completed',
                                      primer: primer1_id)
        data = JSON.parse(response.body)['samples']['data']

        expect(data.length).to eq(1)

        ids = data.map { |i| i['attributes']['id'] }
        expect(ids).to match_array([1])
      end
    end
  end
end
