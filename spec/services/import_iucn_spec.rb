# frozen_string_literal: true

require 'rails_helper'

describe ImportIucn do
  let(:subject) { ImportIucn.new }
  let(:api_data) do
    [
      {
        'taxonid': 1,
        'scientific_name': 'Genus species',
        'subspecies': nil,
        'rank': nil,
        'subpopulation': nil,
        'category': 'LC'
      },
      {
        'taxonid': 2,
        'scientific_name': 'Genus species var. sub1',
        'subspecies': 'sub1',
        'rank': 'var.',
        'subpopulation': nil,
        'category': 'LC'
      },
      {
        'taxonid': 3,
        'scientific_name': 'Genus species ssp. sub2',
        'subspecies': 'sub2',
        'rank': 'ssp.',
        'subpopulation': nil,
        'category': 'LC'
      },
      {
        'taxonid': 4,
        'scientific_name': 'Genus species subsp. sub3',
        'subspecies': 'sub3',
        'rank': 'subsp.',
        'subpopulation': nil,
        'category': 'LC'
      }
    ]
  end

  describe '#process_iucn_status' do
    include ActiveJob::TestHelper

    context 'when taxon exists' do
      it 'updates the taxon iucn_status for species' do
        taxon = create(:ncbi_node, canonical_name: 'Genus species',
                                   rank: 'species')

        expect { subject.process_iucn_status(api_data.first) }
          .to change { taxon.reload.iucn_status }.to('least concern')
      end

      it 'updates the taxon iucn_status for variety' do
        taxon = create(:ncbi_node, canonical_name: 'Genus species sub1',
                                   rank: 'variety')

        expect { subject.process_iucn_status(api_data.second) }
          .to change { taxon.reload.iucn_status }.to('least concern')
      end

      it 'updates the taxon iucn_status for subspecies' do
        taxon = create(:ncbi_node, canonical_name: 'Genus species sub2',
                                   rank: 'subspecies')

        expect { subject.process_iucn_status(api_data.third) }
          .to change { taxon.reload.iucn_status }.to('least concern')
      end

      it 'updates the taxon iucn_status for subspecies' do
        taxon = create(:ncbi_node, canonical_name: 'Genus species sub3',
                                   rank: 'subspecies')

        expect { subject.process_iucn_status(api_data.fourth) }
          .to change { taxon.reload.iucn_status }.to('least concern')
      end
    end

    context 'when taxon does not exist' do
      it 'returns nil' do
        result = subject.process_iucn_status(api_data.second)

        expect(result).to eq(nil)
      end
    end
  end

  describe '#find_rank' do
    it 'returns species when rank is nil' do
      expect(subject.find_rank(api_data.first)).to eq('species')
    end

    it 'returns variety when rank is var.' do
      expect(subject.find_rank(api_data.second)).to eq('variety')
    end

    it 'returns subspecies when rank is ssp.' do
      expect(subject.find_rank(api_data.third)).to eq('subspecies')
    end

    it 'returns subspecies when rank is subsp.' do
      expect(subject.find_rank(api_data.fourth)).to eq('subspecies')
    end
  end

  describe '#form_canonical_name' do
    it 'returns species when rank is species' do
      expected = 'Genus species'
      expect(subject.form_canonical_name(api_data.first)).to eq(expected)
    end

    it 'returns species and subspecies when rank is var.' do
      expected = 'Genus species sub1'
      expect(subject.form_canonical_name(api_data.second)).to eq(expected)
    end

    it 'returns species and subspecies when rank is ssp.' do
      expected = 'Genus species sub2'
      expect(subject.form_canonical_name(api_data.third)).to eq(expected)
    end

    it 'returns species and subspecies when rank is subsp.' do
      expected = 'Genus species sub3'
      expect(subject.form_canonical_name(api_data.fourth)).to eq(expected)
    end
  end
end
