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

  describe '#find_sample' do
    let(:barcode) { 'K0001-LA-S1' }
    let(:project) { create(:field_data_project, name: 'unknown') }

    def subject
      dummy_class.find_sample(barcode)
    end

    context 'there are no samples for a given bar code' do
      it 'creates a new sample' do
        stub_const('FieldDataProject::DEFAULT_PROJECT', project)

        expect { subject }.to change { Sample.count }.by(1)
      end

      it 'returns the created sample' do
        stub_const('FieldDataProject::DEFAULT_PROJECT', project)
        result = subject

        expect(result.barcode).to eq(barcode)
        expect(result.field_data_project).to eq(project)
        expect(result.status_cd).to eq('missing_coordinates')
      end
    end

    context 'there is one valid sample for a given barcode' do
      it 'returns the matching sample' do
        sample = create(:sample, status_cd: :approved, barcode: barcode)
        result = subject

        expect(result).to eq(sample)
      end

      it 'updates status to results_completed' do
        create(:sample, status_cd: :approved, barcode: barcode)
        result = subject

        expect(result.status_cd).to eq('results_completed')
      end

      it 'does not update status when status is missing_coordinates' do
        create(:sample, status_cd: :missing_coordinates, barcode: barcode)
        result = subject

        expect(result.status_cd).to eq('missing_coordinates')
      end
    end

    context 'there is one valid and one invalid sample for a given barcode' do
      it 'returns the matching  valid sample' do
        sample = create(:sample, status_cd: :approved, barcode: barcode)
        create(:sample, status_cd: :rejected, barcode: barcode)
        result = subject

        expect(result).to eq(sample)
      end

      it 'updates status to results_completed' do
        create(:sample, status_cd: :approved, barcode: barcode)
        create(:sample, status_cd: :rejected, barcode: barcode)
        result = subject

        expect(result.status_cd).to eq('results_completed')
      end

      it 'does not update status when status is missing_coordinates' do
        create(:sample, status_cd: :missing_coordinates, barcode: barcode)
        create(:sample, status_cd: :rejected, barcode: barcode)
        result = subject

        expect(result.status_cd).to eq('missing_coordinates')
      end
    end

    context 'there are multiple valid samples for a given barcode' do
      it 'raises an error' do
        create(:sample, status_cd: :approved, barcode: barcode)
        create(:sample, status_cd: :results_completed, barcode: barcode)

        message = /multiple samples with barcode/
        expect { subject }.to raise_error(ImportError, message)
      end
    end

    context 'all samples are rejected for a given barcode' do
      it 'raises an error when there is one sample' do
        create(:sample, status_cd: :rejected, barcode: barcode)

        message = /was previously rejected/
        expect { subject }.to raise_error(ImportError, message)
      end

      it 'raises an error when there are multiple samples' do
        create(:sample, status_cd: :rejected, barcode: barcode)
        create(:sample, status_cd: :rejected, barcode: barcode)

        message = /was previously rejected/
        expect { subject }.to raise_error(ImportError, message)
      end
    end

    context 'all samples are duplicate_barcode for a given bar code' do
      it 'raises an error when there is one sample' do
        create(:sample, status_cd: :duplicate_barcode, barcode: barcode)

        message = /was previously rejected/
        expect { subject }.to raise_error(ImportError, message)
      end

      it 'raises an error when there are multiple samples' do
        create(:sample, status_cd: :duplicate_barcode, barcode: barcode)
        create(:sample, status_cd: :duplicate_barcode, barcode: barcode)

        message = /was previously rejected/
        expect { subject }.to raise_error(ImportError, message)
      end
    end
  end
end
