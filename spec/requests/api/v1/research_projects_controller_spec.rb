# frozen_string_literal: true

require 'rails_helper'

describe 'ResearchProjects' do
  include ControllerHelpers

  before do
    stub_const('Website::DEFAULT_SITE', create(:website, name: 'CALeDNA'))
  end

  describe 'show' do
    let(:project_slug) { 'project-slug' }
    let(:primer1_id) { 100 }
    let(:primer2_id) { 200 }
    let(:primer1_name) { 'primer1' }
    let(:primer2_name) { 'primer2' }
    let(:sample1_id) { 10 }
    let(:sample2_id) { 20 }
    let(:taxon1_id) { 1000 }
    let(:taxon2_id) { 2000 }

    def create_project_samples(project, sample_id: rand(1...100_000_000),
                               substrate: :soil,
                               primer: create(:primer))
      sample = create(:sample, id: sample_id, substrate: substrate,
                               status: :results_completed)
      create(:asv, sample: sample, research_project: project, primer: primer)
      create(:sample_primer, primer: primer, sample: sample,
                             research_project: project)
      refresh_samples_map
    end

    it 'returns OK' do
      project = create(:research_project, slug: project_slug)
      get api_v1_research_project_path(id: project.slug)

      expect(response.status).to eq(200)
    end

    context 'when project does not have samples' do
      it 'returns empty array for samples' do
        project = create(:research_project, slug: project_slug)

        get api_v1_research_project_path(id: project.slug)
        data = JSON.parse(response.body)

        expect(data['samples']['data']).to eq([])
      end
    end

    context 'when project is not published' do
      it 'returns empty array for samples' do
        project = create(:research_project, slug: project_slug,
                                            published: false)
        create_project_samples(project)

        get api_v1_research_project_path(id: project.slug)
        data = JSON.parse(response.body)

        expect(data['samples']['data']).to eq([])
      end
    end

    context 'when project has samples with results' do
      it 'returns the associated samples' do
        project = create(:research_project, slug: project_slug, published: true)
        primer = create(:primer, name: primer1_name, id: primer1_id)
        create_project_samples(project, sample_id: sample1_id, primer: primer)
        create_project_samples(project, sample_id: sample2_id, primer: primer)

        get api_v1_research_project_path(id: project.slug)
        data = JSON.parse(response.body)['samples']['data']

        expect(data.length).to eq(2)

        ids = data.map { |s| s['id'].to_i }
        expect(ids).to match_array([sample1_id, sample2_id])

        primer_ids = data.map { |s| s['primer_ids'] }
        expect(primer_ids).to match_array([[primer1_id], [primer1_id]])

        primer_names = data.map { |s| s['primer_names'] }
        expect(primer_names).to match_array([[primer1_name], [primer1_name]])

        taxa_count = data.map { |s| s['taxa_count'] }
        expect(taxa_count).to match_array([1, 1])
      end

      it 'only includes one instance of a sample' do
        project = create(:research_project, slug: project_slug, published: true)
        sample = create(:sample, :results_completed, id: sample1_id)
        primer1 = create(:primer, name: primer1_name, id: primer1_id)
        primer2 = create(:primer, name: primer2_name, id: primer2_id)
        taxon1 = create(:ncbi_node, taxon_id: taxon1_id)

        create(:asv, sample: sample, research_project: project, primer: primer1,
                     taxon_id: taxon1.taxon_id)
        create(:asv, sample: sample, research_project: project, primer: primer2,
                     taxon_id: taxon1.taxon_id)
        create(:sample_primer, sample: sample, research_project: project,
                               primer: primer1)
        create(:sample_primer, sample: sample, research_project: project,
                               primer: primer2)
        refresh_samples_map

        get api_v1_research_project_path(id: project.slug)
        data = JSON.parse(response.body)['samples']['data']

        expect(data.length).to eq(1)

        ids = data.map { |i| i['id'] }
        expect(ids).to match_array([sample1_id])

        primer_names = data.map { |i| i['primer_names'] }
        expect(primer_names).to match_array([%w[primer1 primer2]])

        primer_ids = data.map { |i| i['primer_ids'] }
        expect(primer_ids).to match_array([[primer1_id, primer2_id]])

        taxa_count = data.map { |i| i['taxa_count'] }
        expect(taxa_count).to match_array([1])
      end

      it 'ignores samples from other projects' do
        project = create(:research_project, slug: project_slug, published: true)
        other_project = create(:research_project, slug: 'other')
        create_project_samples(other_project)

        get api_v1_research_project_path(id: project.slug)
        data = JSON.parse(response.body)

        expect(data['samples']['data']).to eq([])
      end

      it 'returns correct info for multiple primers, samples, projects' do
        primer3_name = 'primer3'
        primer3_id = 300
        taxon3_id = 3000
        sample1 = create(:sample, :results_completed, id: sample1_id)
        sample2 = create(:sample, :results_completed, id: sample2_id)
        proj1 = create(:research_project, slug: project_slug, published: true)
        proj2 = create(:research_project, slug: 'other', published: true)
        taxon1 = create(:ncbi_node, taxon_id: taxon1_id)
        taxon2 = create(:ncbi_node, taxon_id: taxon2_id)
        taxon3 = create(:ncbi_node, taxon_id: taxon3_id)
        primer1 = create(:primer, name: primer1_name, id: primer1_id)
        primer2 = create(:primer, name: primer2_name, id: primer2_id)
        primer3 = create(:primer, name: primer3_name, id: primer3_id)

        create(:asv, sample: sample1, primer: primer1, research_project: proj1,
                     taxon_id: taxon1.id)
        create(:asv, sample: sample1, primer: primer1, research_project: proj1,
                     taxon_id: taxon2.id)
        create(:asv, sample: sample1, primer: primer2, research_project: proj1,
                     taxon_id: taxon1.id)
        create(:sample_primer, primer: primer1, sample: sample1,
                               research_project: proj1)
        create(:sample_primer, primer: primer2, sample: sample1,
                               research_project: proj1)

        create(:asv, sample: sample2, primer: primer2, research_project: proj1,
                     taxon_id: taxon2.id)
        create(:asv, sample: sample2, primer: primer3, research_project: proj1,
                     taxon_id: taxon3.id)
        create(:sample_primer, primer: primer3, sample: sample2,
                               research_project: proj1)
        create(:sample_primer, primer: primer2, sample: sample2,
                               research_project: proj1)

        create(:asv, sample: sample1, primer: primer3, research_project: proj2,
                     taxon_id: taxon1.id)
        create(:sample_primer, primer: primer3, sample: sample1,
                               research_project: proj2)
        refresh_samples_map

        get api_v1_research_project_path(id: proj1.slug)
        data = JSON.parse(response.body)['samples']['data']

        expect(data.length).to eq(2)

        ids = data.map { |i| i['id'] }
        expect(ids).to match_array([sample1_id, sample2_id])

        primer_names = data.map { |i| i['primer_names'] }
        expect(primer_names)
          .to match_array([%w[primer1 primer2], %w[primer2 primer3]])

        primer_ids = data.map { |i| i['primer_ids'] }
        expect(primer_ids)
          .to match_array([[primer1_id, primer2_id], [primer2_id, primer3_id]])

        taxa_count = data.map { |s| s['taxa_count'] }
        expect(taxa_count).to match_array([2, 2])
      end
    end

    it 'does not return samples without results' do
      create(:sample, status: :approved)
      create(:sample, status: :submitted)
      project = create(:research_project, slug: project_slug, published: true)
      refresh_samples_map

      get api_v1_research_project_path(id: project.slug)
      data = JSON.parse(response.body)['samples']['data']

      expect(data.length).to eq(0)
    end

    context 'keyword query param' do
      let(:project) do
        create(:research_project, slug: project_slug, published: true)
      end

      before(:each) do
        create_project_samples(project, sample_id: sample1_id)
        create_project_samples(project, sample_id: sample2_id)

        ActiveRecord::Base.connection.execute(
          <<-SQL
          INSERT INTO "pg_search_documents"
          ("content", "searchable_type", "searchable_id", "created_at",
          "updated_at")
          VALUES('match', 'Sample', #{sample1_id}, '2018-10-20', '2018-10-20');
          SQL
        )
        refresh_samples_map
      end

      it 'does not affect the associated samples' do
        get api_v1_research_project_path(id: project.slug, keyword: 'match')
        data = JSON.parse(response.body)['samples']['data']

        expect(data.length).to eq(2)

        ids = data.map { |i| i['id'] }
        expect(ids).to match_array([sample1_id, sample2_id])
      end
    end

    context 'substrate query param' do
      let(:project) do
        create(:research_project, slug: project_slug, published: true)
      end

      before(:each) do
        create_project_samples(project, substrate: :soil)
        create_project_samples(project, substrate: :sediment)
      end

      it 'returns samples when there is one substrate' do
        get api_v1_research_project_path(id: project.slug, substrate: :soil)
        data = JSON.parse(response.body)['samples']['data']

        expect(data.length).to eq(1)

        substrate = data.map { |i| i['substrate'] }
        expect(substrate).to match_array(['soil'])
      end

      it 'returns samples when there are multiple substrate' do
        get api_v1_research_project_path(id: project.slug,
                                         substrate: 'soil|sediment')
        data = JSON.parse(response.body)['samples']['data']

        expect(data.length).to eq(2)

        substrate = data.map { |i| i['substrate'] }
        expect(substrate).to match_array(%w[sediment soil])
      end
    end

    context 'status query param' do
      let(:project) do
        create(:research_project, slug: project_slug, published: true)
      end

      before(:each) do
        create(:sample, status: :approved)
        create_project_samples(project, sample_id: sample2_id)
        refresh_samples_map
      end

      it 'ignores status params and only returns completed samples ' do
        get api_v1_research_project_path(id: project.slug, status: 'foo')
        data = JSON.parse(response.body)['samples']['data']

        expect(data.length).to eq(1)

        ids = data.map { |i| i['id'] }
        expect(ids).to match_array([sample2_id])
      end
    end

    context 'primer query param' do
      let(:project) do
        create(:research_project, slug: project_slug, published: true)
      end
      let(:primer1) { create(:primer, name: primer1_name, id: primer1_id) }
      let(:primer2) { create(:primer, name: primer2_name, id: primer2_id) }

      it 'returns samples when there is one primer' do
        create_project_samples(project, primer: primer1, sample_id: sample1_id)
        create_project_samples(project, primer: primer2)

        get api_v1_research_project_path(id: project.slug, primer: primer1_id)
        data = JSON.parse(response.body)['samples']['data']

        expect(data.length).to eq(1)

        ids = data.map { |i| i['id'] }
        expect(ids).to match_array([sample1_id])

        primer_names = data.map { |i| i['primer_names'] }
        expect(primer_names).to match_array([['primer1']])

        primer_ids = data.map { |i| i['primer_ids'] }
        expect(primer_ids).to match_array([[primer1_id]])

        taxa_count = data.map { |s| s['taxa_count'] }
        expect(taxa_count).to match_array([1])
      end

      it 'returns samples when there are multiple primer' do
        sample3_id = 300
        sample1 = create(:sample, :results_completed, id: sample1_id)
        create(:asv, sample: sample1, research_project: project,
                     primer: primer1)
        create(:asv, sample: sample1, research_project: project,
                     primer: primer2)
        create(:sample_primer, primer: primer1, sample: sample1,
                               research_project: project)
        create(:sample_primer, primer: primer2, sample: sample1,
                               research_project: project)

        create_project_samples(project, primer: primer1, sample_id: sample2_id)
        create_project_samples(project, primer: primer2, sample_id: sample3_id)
        refresh_samples_map

        get api_v1_research_project_path(id: project.slug,
                                         primer: "#{primer1_id}|#{primer2_id}")
        data = JSON.parse(response.body)['samples']['data']

        expect(data.length).to eq(3)

        ids = data.map { |i| i['id'] }
        expect(ids).to match_array([sample1_id, sample2_id, sample3_id])

        primer_names = data.map { |i| i['primer_names'] }
        expect(primer_names)
          .to match_array([%w[primer1 primer2], ['primer2'], ['primer1']])

        primer_ids = data.map { |i| i['primer_ids'] }
        expect(primer_ids)
          .to match_array([[primer1_id, primer2_id], [primer2_id],
                           [primer1_id]])

        taxa_count = data.map { |s| s['taxa_count'] }
        expect(taxa_count).to match_array([2, 1, 1])
      end

      it 'ignores invalid primers' do
        create_project_samples(project, primer: primer1)
        create_project_samples(project, primer: primer2)

        get api_v1_research_project_path(id: project.slug, primer: 999)
        data = JSON.parse(response.body)['samples']['data']

        expect(data.length).to eq(0)
      end
    end

    context 'multiple query params' do
      let(:project) do
        create(:research_project, slug: project_slug, published: true)
      end

      it 'returns samples that match substrate & primer' do
        sample3_id = 30
        sample4_id = 40
        primer1 = create(:primer, id: primer1_id)
        primer2 = create(:primer, id: primer2_id)
        create_project_samples(project, sample_id: sample1_id, substrate: :soil,
                                        primer: primer1)
        create_project_samples(project, sample_id: sample2_id, substrate: :foo,
                                        primer: primer1)
        create_project_samples(project, sample_id: sample3_id, substrate: :soil,
                                        primer: primer2)
        create(:sample, :approved, id: sample4_id)
        refresh_samples_map

        get api_v1_research_project_path(id: project.slug, substrate: 'soil',
                                         primer: primer1_id)
        data = JSON.parse(response.body)['samples']['data']

        expect(data.length).to eq(1)

        ids = data.map { |i| i['id'] }
        expect(ids).to match_array([sample1_id])
      end
    end
  end
end
