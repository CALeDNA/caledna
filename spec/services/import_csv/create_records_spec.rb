# frozen_string_literal: true

require 'rails_helper'

describe ImportCsv::CreateRecords do
  let(:dummy_class) { Class.new { extend ImportCsv::CreateRecords } }

  describe '#create_asv' do
    def subject(cell, extraction, taxon)
      dummy_class.create_asv(cell, extraction, taxon)
    end
    let(:extraction) { create(:extraction, sample: create(:sample)) }
    let(:taxon) { create(:ncbi_node) }

    context 'asv does not already exists' do
      it 'creates asv' do
        cell = 'K0001.A1'

        expect { subject(cell, extraction, taxon) }.to change(Asv, :count).by(1)
      end

      it 'does not add primer if cell does not have primer info' do
        cell = 'K0001.A1'
        subject(cell, extraction, taxon)
        asv = Asv.last

        expect(asv.primers).to eq([])
      end

      it 'adds primer if cell has primer info' do
        cell = 'X12_K0001.A1'
        subject(cell, extraction, taxon)
        asv = Asv.last

        expect(asv.primers).to eq(['X12'])
      end
    end

    context 'asv already exists' do
      it 'does not create asv' do
        cell = 'K0001.A1'
        create(:asv, extraction: extraction, taxonID: taxon.taxon_id)

        expect { subject(cell, extraction, taxon) }.to change(Asv, :count).by(0)
      end

      it 'adds new primer if cell has primer info' do
        cell = 'X12_K0001.A1'
        create(:asv, extraction: extraction, taxonID: taxon.taxon_id,
                     primers: ['X16'])
        subject(cell, extraction, taxon)
        asv = Asv.last

        expect(asv.primers).to eq(%w[X16 X12])
      end

      it 'does not add duplicate primer if cell has primer info' do
        cell = 'X12_K0001.A1'
        create(:asv, extraction: extraction, taxonID: taxon.taxon_id,
                     primers: ['X12'])
        subject(cell, extraction, taxon)
        asv = Asv.last

        expect(asv.primers).to eq(['X12'])
      end
    end
  end
end
