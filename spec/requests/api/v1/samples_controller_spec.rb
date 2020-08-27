# frozen_string_literal: true

require 'rails_helper'

describe 'Samples' do
  include ControllerHelpers

  before do
    create(:website, name: Website::DEFAULT_SITE)
    create(:research_project, name: 'Los Angeles River')
    create(:field_project, name: 'Los Angeles River')
  end

  let(:field_river) { FieldProject.la_river }
  let(:research_river) { ResearchProject.la_river }

  describe 'index' do
    # rubocop:disable Metrics/MethodLength
    def created_completed_sample(sample_id: 1, substrate: :soil)
      sample = create(:sample,
                      :results_completed,
                      id: sample_id,
                      substrate: substrate,
                      field_project: field_river)
      rproj = research_river
      rproj.update(published: true)
      primer = create(:primer)
      create(:sample_primer, research_project: rproj, sample: sample,
                             primer: primer)
      create(:asv, research_project: rproj, sample: sample,
                   primer: primer)
      refresh_samples_map
    end
    # rubocop:enable Metrics/MethodLength

    it 'returns OK' do
      get api_v1_samples_path

      expect(response.status).to eq(200)
    end

    it 'returns all valid samples' do
      create(:sample, :approved, field_project: field_river)
      created_completed_sample

      get api_v1_samples_path

      json = JSON.parse(response.body)

      expect(json['samples']['data'].length).to eq(2)
    end

    it 'ignores invalid samples' do
      create_list(:sample, 3, field_project: field_river)
      refresh_samples_map
      get api_v1_samples_path

      json = JSON.parse(response.body)

      expect(json['samples']['data'].length).to eq(0)
    end

    it 'does not return samples from unpublished research projects' do
      rproj = research_river
      rproj.update(published: false)
      sample = create(:sample, :results_completed, field_project: field_river)
      primer = create(:primer)
      create(:asv, sample: sample, research_project: rproj, primer: primer)
      create(:sample_primer, sample: sample, research_project: rproj,
                             primer: primer)
      refresh_samples_map

      get api_v1_samples_path
      data = JSON.parse(response.body)

      expect(data['samples']['data']).to eq([])
    end

    it 'returns approved samples or published result_completed samples' do
      primer = create(:primer)

      sample1 = create(:sample, :results_completed)
      rproj1 = create(:research_project, published: false)
      create(:sample_primer, research_project: rproj1, sample: sample1,
                             primer: primer)
      create(:asv, research_project: rproj1, sample: sample1, primer: primer)

      sample2 = create(:sample, :results_completed, field_project: field_river)
      rproj2 = research_river
      rproj2.update(published: true)
      create(:sample_primer, research_project: rproj2, sample: sample2,
                             primer: primer)
      create(:asv, research_project: rproj2, sample: sample2, primer: primer)

      sample3 = create(:sample, :approved, field_project: field_river)
      refresh_samples_map

      get api_v1_samples_path
      data = JSON.parse(response.body)

      expect(data['samples']['data'].length).to eq(2)

      ids = data['samples']['data'].map { |s| s['id'].to_i }
      expect(ids).to match_array([sample3.id, sample2.id])
    end

    context 'keyword query param' do
      before(:each) do
        create(:sample, :approved, id: 1, field_project: field_river)
        create(:sample, :approved, id: 2, field_project: field_river)
        created_completed_sample(sample_id: 3)

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
        refresh_samples_map
      end

      it 'returns samples that contain the keyword' do
        get api_v1_samples_path(keyword: 'match')
        data = JSON.parse(response.body)['samples']['data']

        expect(data.length).to eq(2)

        ids = data.map { |i| i['id'] }
        expect(ids).to match_array([1, 2])
      end

      it 'returns empty array if no samples contain the keyword' do
        get api_v1_samples_path(keyword: 'random')
        data = JSON.parse(response.body)['samples']['data']

        expect(data).to eq([])
      end
    end

    context 'substrate query param' do
      before(:each) do
        create(:sample, :approved, substrate_cd: :soil,
                                   field_project: field_river)
        create(:sample, :approved, substrate_cd: :bad,
                                   field_project: field_river)
        created_completed_sample(substrate: :sediment)
        refresh_samples_map
      end

      it 'returns samples when there is one substrate' do
        get api_v1_samples_path(substrate: :soil)
        data = JSON.parse(response.body)['samples']['data']

        expect(data.length).to eq(1)

        substrate = data.map { |i| i['substrate'] }
        expect(substrate).to eq(['soil'])
      end

      it 'returns samples when there are multiple substrate' do
        get api_v1_samples_path(substrate: 'soil|sediment')
        data = JSON.parse(response.body)['samples']['data']

        expect(data.length).to eq(2)

        substrate = data.map { |i| i['substrate'] }
        expect(substrate).to match_array(%w[sediment soil])
      end
    end

    context 'status query param' do
      before(:each) do
        create(:sample, status_cd: :approved, field_project: field_river)
        created_completed_sample
        refresh_samples_map
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
      let(:primer1_name) { 'primer1' }
      let(:primer2_name) { 'primer2' }

      before(:each) do
        create(:sample, :approved, field_project: field_river)
        s1 = create(:sample, :results_completed, field_project: field_river)
        s2 = create(:sample, :results_completed, field_project: field_river)
        p1 = create(:primer, name: primer1_name, id: primer1_id)
        p2 = create(:primer, name: primer2_name, id: primer2_id)
        rproj = research_river
        rproj.update(published: true)

        create(:asv, sample: s1, primer: p1, research_project: rproj)
        create(:sample_primer, sample: s1, primer: p1, research_project: rproj)
        create(:asv, sample: s1, primer: p1, research_project: rproj)
        create(:sample_primer, sample: s1, primer: p1, research_project: rproj)

        create(:asv, sample: s1, primer: p1, research_project: rproj)
        create(:sample_primer, sample: s1, primer: p1, research_project: rproj)
        create(:asv, sample: s1, primer: p1, research_project: rproj)
        create(:sample_primer, sample: s1, primer: p1, research_project: rproj)

        create(:asv, sample: s2, primer: p2, research_project: rproj)
        create(:sample_primer, sample: s2, primer: p2, research_project: rproj)
        refresh_samples_map
      end

      it 'returns samples when there is one primer' do
        get api_v1_samples_path(primer: primer1_id)
        data = JSON.parse(response.body)['samples']['data']

        expect(data.length).to eq(1)

        primer_names = data.map { |i| i['primer_names'] }
        expect(primer_names).to match_array([[primer1_name]])

        primer_ids = data.map { |i| i['primer_ids'] }
        expect(primer_ids).to match_array([[primer1_id]])
      end

      it 'returns samples when there are multiple primer' do
        get api_v1_samples_path(primer: "#{primer1_id}|#{primer2_id}")
        data = JSON.parse(response.body)['samples']['data']

        expect(data.length).to eq(2)

        primer_names = data.map { |i| i['primer_names'] }
        expect(primer_names).to match_array([[primer1_name], [primer2_name]])

        primer_ids = data.map { |i| i['primer_ids'] }
        expect(primer_ids).to match_array([[primer1_id], [primer2_id]])
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
        s1 = create(:sample, :results_completed, id: 1, substrate_cd: :soil,
                                                 field_project: field_river)
        s2 = create(:sample, :results_completed, id: 2, substrate_cd: :soil,
                                                 field_project: field_river)
        s3 = create(:sample, :results_completed, id: 3, substrate_cd: :foo,
                                                 field_project: field_river)
        create(:sample, :geo, id: 4, substrate_cd: :soil, status_cd: :rejected,
                              field_project: field_river)
        s5 = create(:sample, :results_completed, id: 5, substrate_cd: :soil,
                                                 field_project: field_river)
        create(:sample, :approved, id: 6, substrate_cd: :soil,
                                   field_project: field_river)
        create(:sample, :approved, id: 7, field_project: field_river)
        p1 = create(:primer, name: '12S', id: primer1_id)
        p2 = create(:primer, name: '18S', id: primer2_id)
        rproj = research_river
        rproj.update(published: true)

        create(:asv, sample: s1, primer: p1, research_project: rproj)
        create(:sample_primer, sample: s1, primer: p1, research_project: rproj)
        create(:asv, sample: s1, primer: p1, research_project: rproj)
        create(:sample_primer, sample: s1, primer: p1, research_project: rproj)
        create(:asv, sample: s2, primer: p1, research_project: rproj)
        create(:sample_primer, sample: s2, primer: p1, research_project: rproj)
        create(:asv, sample: s3, primer: p1, research_project: rproj)
        create(:sample_primer, sample: s3, primer: p2, research_project: rproj)
        create(:asv, sample: s5, primer: p1, research_project: rproj)
        create(:sample_primer, sample: s5, primer: p2, research_project: rproj)

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
        refresh_samples_map
      end

      it 'returns samples that match substrate & status' do
        get api_v1_samples_path(substrate: 'soil',
                                status: 'results_completed')
        data = JSON.parse(response.body)['samples']['data']

        expect(data.length).to eq(3)

        ids = data.map { |i| i['id'] }
        expect(ids).to match_array([1, 2, 5])
      end

      it 'returns samples that match substrate & primer' do
        get api_v1_samples_path(substrate: 'soil',
                                primer: primer1_id)
        data = JSON.parse(response.body)['samples']['data']

        expect(data.length).to eq(3)

        ids = data.map { |i| i['id'] }
        expect(ids).to match_array([1, 2, 5])
      end

      it 'returns samples that match substrate & keyword' do
        get api_v1_samples_path(substrate: 'soil',
                                keyword: 'match')
        data = JSON.parse(response.body)['samples']['data']

        expect(data.length).to eq(2)

        ids = data.map { |i| i['id'] }
        expect(ids).to match_array([1, 6])
      end

      it 'returns samples that match all the query params' do
        get api_v1_samples_path(substrate: 'soil',
                                status: 'results_completed',
                                keyword: 'match',
                                primer: primer1_id)
        data = JSON.parse(response.body)['samples']['data']

        expect(data.length).to eq(1)

        ids = data.map { |i| i['id'] }
        expect(ids).to eq([1])
      end
    end
  end

  describe 'show' do
    it 'returns OK when sample is approved' do
      sample = create(:sample, :approved, field_project: field_river)
      refresh_samples_map

      get api_v1_sample_path(id: sample.id)

      expect(response.status).to eq(200)
    end

    context 'when sample is approved' do
      it 'returns the sample data for the given sample' do
        sample = create(:sample, :approved, field_project: field_river)
        refresh_samples_map

        get api_v1_sample_path(id: sample.id)
        data = JSON.parse(response.body)

        expect(data['sample']['data']['id'].to_i).to eq(sample.id)
      end
    end

    context 'when sample has results' do
      context 'and research project is published' do
        it 'returns the sample data for the given sample' do
          sample = create(:sample, :results_completed,
                          field_project: field_river)
          rproj = research_river
          rproj.update(published: true)
          primer = create(:primer)
          create(:sample_primer, sample: sample, primer: primer,
                                 research_project: rproj)
          create(:asv, sample: sample, primer: primer,
                       research_project: rproj)
          refresh_samples_map

          get api_v1_sample_path(id: sample.id)
          data = JSON.parse(response.body)['sample']['data']

          expect(data['id'].to_i).to eq(sample.id)
        end
      end

      context 'and research project is not published' do
        it 'returns nil' do
          sample = create(:sample, :results_completed,
                          field_project: field_river)
          rproj = research_river
          rproj.update(published: false)
          primer = create(:primer)
          create(:sample_primer, sample: sample, primer: primer,
                                 research_project: rproj)
          create(:sample_primer, sample: sample, primer: primer,
                                 research_project: rproj)
          refresh_samples_map

          get api_v1_sample_path(id: sample.id)
          data = JSON.parse(response.body)['sample']['data']

          expect(data).to eq(nil)
        end
      end
    end

    it 'returns nil if sample is not approved' do
      sample = create(:sample, status_cd: :submitted, latitude: 1, longitude: 1,
                               field_project: field_river)
      refresh_samples_map

      get api_v1_sample_path(id: sample.id)
      data = JSON.parse(response.body)['sample']['data']

      expect(data).to eq(nil)
    end

    it 'returns a sample if sample does not have coordinates' do
      sample = create(:sample, status_cd: :approved, latitude: nil,
                               longitude: nil, field_project: field_river)
      refresh_samples_map

      get api_v1_sample_path(id: sample.id)
      data = JSON.parse(response.body)

      expect(data['sample']['data']['id'].to_i).to eq(sample.id)
    end

    it 'returns nil for invalid id' do
      get api_v1_sample_path(id: 1)
      data = JSON.parse(response.body)

      expect(data['sample']['data']).to eq(nil)
    end
  end
end
