# frozen_string_literal: true

require 'rails_helper'

describe ImportCsv::DnaResults do
  let(:dummy_class) { Class.new { extend ImportCsv::DnaResults } }

  describe '#convert_header_to_barcode' do
    def subject(header)
      dummy_class.convert_header_to_barcode(header)
    end

    it 'converts header into valid kit number' do
      header = 'X16S_K0078.C2.S59.L001'

      expect(subject(header)).to eq('K0078-LC-S2')
    end

    it 'converts header into a random sample number' do
      header = 'X16S_ShrubBlank1.S72.L001'

      expect(subject(header)).to eq('ShrubBlank1')
    end
  end
end
