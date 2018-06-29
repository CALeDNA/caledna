# frozen_string_literal: true

require 'rails_helper'

describe ImportCsv::CreateRecords do
  let(:dummy_class) { Class.new { extend ImportCsv::CreateRecords } }

  describe '#create_asv' do
    def subject(cell, extraction, cal_taxon)
      dummy_class.create_asv(cell, extraction, cal_taxon)
    end
    let(:sample) { create(:sample) }
    let(:extraction) { create(:extraction, sample: sample) }
    let(:taxon) { create(:ncbi_node, asvs_count: 0, taxon_id: 1, ids: [1]) }
    let(:cal_taxon) { create(:cal_taxon, taxonID: taxon.taxon_id) }

    context 'asv does not already exists' do
      it 'creates asv' do
        cell = 'K0001.A1'

        expect { subject(cell, extraction, cal_taxon) }
          .to change(Asv, :count).by(1)
      end

      it 'does not add primer if cell does not have primer info' do
        cell = 'K0001.A1'
        subject(cell, extraction, cal_taxon)
        asv = Asv.last

        expect(asv.primers).to eq([])
      end

      it 'adds primer if cell has primer info' do
        cell = 'X12_K0001.A1'
        subject(cell, extraction, cal_taxon)
        asv = Asv.last

        expect(asv.primers).to eq(['X12'])
      end
    end

    context 'asv already exists' do
      it 'does not create asv' do
        cell = 'K0001.A1'
        create(:asv, extraction: extraction, sample: sample,
                     taxonID: cal_taxon.taxonID)

        expect { subject(cell, extraction, cal_taxon) }
          .to change(Asv, :count).by(0)
      end

      it 'adds new primer if cell has primer info' do
        cell = 'X12_K0001.A1'
        create(:asv, extraction: extraction, taxonID: cal_taxon.taxonID,
                     sample: sample, primers: ['X16'])
        subject(cell, extraction, cal_taxon)
        asv = Asv.last

        expect(asv.primers).to eq(%w[X16 X12])
      end

      it 'does not add duplicate primer if cell has primer info' do
        cell = 'X12_K0001.A1'
        create(:asv, extraction: extraction, taxonID: cal_taxon.taxonID,
                     sample: sample, primers: ['X12'])
        subject(cell, extraction, cal_taxon)
        asv = Asv.last

        expect(asv.primers).to eq(['X12'])
      end
    end
  end
end
