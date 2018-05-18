# frozen_string_literal: true

require 'rails_helper'

describe ImportCsv::CreateRecords do
  let(:dummy_class) { Class.new { extend ImportCsv::CreateRecords } }

  describe '#create_asv' do
    def subject(cell, extraction, cal_taxon)
      dummy_class.create_asv(cell, extraction, cal_taxon)
    end
    let(:extraction) { create(:extraction, sample: create(:sample)) }
    let(:taxon) { create(:ncbi_node) }
    let(:cal_taxon) { create(:cal_taxon, taxonID: taxon.id) }

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
        create(:asv, extraction: extraction, taxonID: cal_taxon.taxonID)

        expect { subject(cell, extraction, cal_taxon) }
          .to change(Asv, :count).by(0)
      end

      it 'adds new primer if cell has primer info' do
        cell = 'X12_K0001.A1'
        create(:asv, extraction: extraction, taxonID: cal_taxon.taxonID,
                     primers: ['X16'])
        subject(cell, extraction, cal_taxon)
        asv = Asv.last

        expect(asv.primers).to eq(%w[X16 X12])
      end

      it 'does not add duplicate primer if cell has primer info' do
        cell = 'X12_K0001.A1'
        create(:asv, extraction: extraction, taxonID: cal_taxon.taxonID,
                     primers: ['X12'])
        subject(cell, extraction, cal_taxon)
        asv = Asv.last

        expect(asv.primers).to eq(['X12'])
      end
    end
  end
end
