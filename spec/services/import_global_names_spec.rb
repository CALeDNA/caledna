# frozen_string_literal: true

require 'rails_helper'

describe ImportGlobalNames do
  let(:dummy_class) { Class.new { extend ImportGlobalNames } }

  let(:api_data) do
    {
      'data': [
        {
          'results': [
            {
              'data_source_id': 4,
              'data_source_title': 'NCBI',
              'name_string': 'Canis lupus',
              'canonical_form': 'Canis lupus',
              'taxon_id': '1',
              'vernaculars': [
                {
                  'name': 'gray wolf',
                  'language': 'ENg'
                },
                {
                  'name': 'grey wolf',
                  'language': 'eN'
                },
                {
                  'name': 'wolf',
                  'language': 'eNGLish'
                }
              ],
              'score': 0.9
            },
            {
              'data_source_id': 10,
              'data_source_title': 'Freebase',
              'name_string': 'Canis lupus',
              'canonical_form': 'Canis lupus',
              'taxon_id': '2',
              'vernaculars': [],
              'match_type': 1,
              'score': 0.9
            },
            {
              'data_source_id': 12,
              'data_source_title': 'EOL',
              'name_string': 'Canis lupus',
              'canonical_form': 'Canis lupus',
              'taxon_id': '3',
              'vernaculars': [
                {
                  'name': 'Prairie Wolf',
                  'language': nil

                },
                {
                  'name': '尖',
                  'language': 'Chinese'
                },
                {
                  'name': 'WOlf',
                  'language': 'eNGLish'
                }
              ],
              'score': 0.8
            },
            {
              'data_source_id': 4,
              'data_source_title': 'NCBI',
              'name_string': 'Canis lupus familar',
              'canonical_form': 'Canis lupus familar',
              'taxon_id': '5',
              'vernaculars': [],
              'score': 0.9
            }
          ]
        }
      ]
    }.with_indifferent_access
  end

  describe '#create_external_resource' do
    def subject(api_data, taxon_id, id_name)
      dummy_class.create_external_resource(
        results: api_data, taxon_id: taxon_id, id_name: id_name
      )
    end

    let(:taxon_id) { 1 }
    let(:id_name) { 'ncbi_id' }

    it 'creates an external resource if it does not exist' do
      expect { subject(api_data, taxon_id, id_name) }
        .to change(ExternalResource, :count).by(1)
    end

    it 'creates an external resource with data from api' do
      subject(api_data, taxon_id, id_name)
      resource = ExternalResource.first

      expect(resource.ncbi_id).to eq(1)
      expect(resource.eol_id).to eq(3)
      expect(resource.source).to eq('globalnames')
      expect(resource.payload).to eq(api_data)
    end

    it 'saves nested vernaculars from the apis as a flat array' do
      stub_const('ImportGlobalNames::SCORE_THRESHOLD', 0.7)
      subject(api_data, taxon_id, id_name)
      resource = ExternalResource.first

      expect(resource.vernaculars)
        .to eq(['gray wolf', 'grey wolf', 'wolf', 'prairie wolf'])
    end

    it 'sets low_score to false if all scores are above threshold' do
      stub_const('ImportGlobalNames::SCORE_THRESHOLD', 0.7)
      subject(api_data, taxon_id, id_name)
      resource = ExternalResource.first

      expect(resource.low_score).to eq(false)
    end

    it 'sets low_score to true if any score is below threshold' do
      stub_const('ImportGlobalNames::SCORE_THRESHOLD', 0.85)
      subject(api_data, taxon_id, id_name)
      resource = ExternalResource.first

      expect(resource.low_score).to eq(true)
    end

    it 'returns nil if api returns no data' do
      api_data = {}

      expect(subject(api_data, taxon_id, id_name)).to eq(nil)
    end

    it 'returns nil if api does not return a match' do
      api_data = {
        data: [
          {
            supplied_name_string: 'boo',
            is_known_name: false
          }
        ]
      }

      expect(subject(api_data, taxon_id, id_name)).to eq(nil)
    end
  end
end
