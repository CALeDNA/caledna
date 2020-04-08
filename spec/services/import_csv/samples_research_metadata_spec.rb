# frozen_string_literal: true

require 'rails_helper'

describe ImportCsv::SamplesResearchMetadata do
  let(:dummy_class) { Class.new { extend ImportCsv::SamplesResearchMetadata } }

  describe('#import_csv') do
    def subject(file, research_project_id)
      dummy_class.import_csv(file, research_project_id)
    end

    let(:csv) { './spec/fixtures/import_csv/samples_metadata.csv' }
    let(:file) { fixture_file_upload(csv, 'text/csv') }
    let(:research_project_id) { create(:research_project, name: 'foo').id }
    let(:barcode1) { 'K9999-A1' }
    let(:barcode2) { 'K9999-A2' }

    context 'when CSV has barcodes that are not in the database' do
      before(:each) do
        create(:sample, barcode: barcode1)
      end

      it 'returns an error' do
        results = subject(file, research_project_id)
        expect(results.valid?).to eq(false)
        expect(results.errors).to eq("#{barcode2} not in the database")
      end

      it 'does not create ResearchProjectSource' do
        expect { subject(file, research_project_id) }
          .to change { ResearchProjectSource.count }.by(0)
      end
    end

    context 'when CSV barcodes are all in the database' do
      let!(:sample1) { create(:sample, barcode: barcode1) }
      let!(:sample2) { create(:sample, barcode: barcode2) }

      it 'returns valid' do
        results = subject(file, research_project_id)
        expect(results.valid?).to eq(true)
      end

      it 'creates ResearchProjectSource' do
        expect { subject(file, research_project_id) }
          .to change { ResearchProjectSource.count }.by(2)
      end

      it 'creates ResearchProjectSource using csv data' do
        subject(file, research_project_id)
        source = ResearchProjectSource.first

        expect(source.sourceable).to eq(sample1)
        expect(source.research_project_id).to eq(research_project_id)
        expect(source.metadata).to eq('field1' => 'a', 'field2' => 'b')
      end
    end
  end
end
