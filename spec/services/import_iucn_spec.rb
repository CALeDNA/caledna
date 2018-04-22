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
  #  var 65, subsp 30, ssp 107

  describe '#update_iucn_status' do
    it 'updates iunc_status when matching taxon is found' do
      taxon = create(:taxon, canonicalName: 'Genus species sub1',
                             taxonRank: 'variety', iucn_status: nil)
      subject.update_iucn_status(api_data.second)
      taxon.reload

      expect(taxon.iucn_status).to eq('LC')
    end

    it 'does not update iunc_status when no matching taxon' do
      taxon = create(:taxon, canonicalName: 'random',
                             taxonRank: 'species', iucn_status: nil)
      subject.update_iucn_status(api_data.second)

      expect(taxon.iucn_status).to eq(nil)
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
