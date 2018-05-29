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

  describe '#process_iucn_status' do
    include ActiveJob::TestHelper

    context 'when taxon exists' do
      let!(:taxon) do
        create(:ncbi_node, canonical_name: 'Genus species sub1',
                           rank: 'variety')
      end

      it 'adds UpdateIucnStatusJob to the queue' do
        expect { subject.process_iucn_status(api_data.second) }
          .to have_enqueued_job(UpdateIucnStatusJob)
      end
    end

    context 'when taxon does not exist' do
      it 'returns nil' do
        result = subject.process_iucn_status(api_data.second)

        expect(result).to eq(nil)
      end
    end
  end

  describe '#update_iucn_status' do
    context 'when taxon exists' do
      let!(:taxon) do
        create(:ncbi_node, canonical_name: 'Genus species sub1',
                          rank: 'variety')
      end

      context 'and external resource exists' do
        context 'and external resource has iucn info' do
          let!(:external_resource) do
            create(:external_resource, taxon_id: taxon.id,
                                      iucn_status: 'status', iucn_id: 1)
          end

          it 'does not update iucn_status' do
            expect { subject.update_iucn_status(api_data.second, taxon) }
              .to_not change { external_resource.reload.iucn_status }
          end

          it 'does not update iucn_id' do
            expect { subject.update_iucn_status(api_data.second, taxon) }
              .to_not change { external_resource.reload.iucn_id }
          end
        end

        context 'and external resource does not have iucn info' do
          let!(:external_resource) do
            create(:external_resource, taxon_id: taxon.id)
          end

          it 'updates iucn data' do
            expect { subject.update_iucn_status(api_data.second, taxon) }
              .to change { external_resource.reload.iucn_status }
              .from(nil).to(IucnStatus::CATEGORIES[:LC])
              .and change { external_resource.reload.iucn_id }
              .from(nil).to(2)
          end
        end
      end

      context 'and external resource does not exist' do
        it 'creates an external resource' do
          expect { subject.update_iucn_status(api_data.second, taxon) }
            .to change { ExternalResource.count }
            .by(1)
        end

        it 'sets iucn data' do
          subject.update_iucn_status(api_data.second, taxon)
          external_resource = ExternalResource.first

          expect(external_resource.iucn_status)
            .to eq(IucnStatus::CATEGORIES[:LC])
          expect(external_resource.iucn_id).to eq(2)
        end
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
