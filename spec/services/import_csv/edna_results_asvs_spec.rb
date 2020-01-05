# frozen_string_literal: true

require 'rails_helper'

describe ImportCsv::EdnaResultsAsvs do
  let(:dummy_class) { Class.new { extend ImportCsv::EdnaResultsAsvs } }

  describe('#import_csv') do
    include ActiveJob::TestHelper

    before(:each) do
      project = create(:field_project, name: 'unknown')
      stub_const('FieldProject::DEFAULT_PROJECT', project)
    end

    def subject(file, research_project_id, primer)
      dummy_class.import_csv(file, research_project_id, primer)
    end

    let(:csv) { './spec/fixtures/import_csv/dna_results_tabs.csv' }
    let(:file) { fixture_file_upload(csv, 'text/csv') }
    let(:research_project) { create(:research_project) }
    let(:primer) { '12S' }
    let(:csv_barcode1) { 'K0001-LA-S1' }
    let(:csv_barcode2) { 'K0001-LA-S2' }

    context 'when barcodes in CSV match samples in the database' do
      before(:each) do
        create(:sample, barcode: csv_barcode1, status: 'approved', id: 999)
        create(:sample, barcode: csv_barcode2, status: 'approved', id: 888)
      end

      it 'adds ImportCsvQueueAsvJob to queue' do
        expect do
          subject(file, research_project.id, primer)
        end
          .to have_enqueued_job(ImportCsvQueueAsvJob)
      end

      it 'adds pass correct agruments to ImportCsvQueueAsvJob' do
        delimiter = "\t"
        data = CSV.read(file.path, headers: true, col_sep: delimiter)

        expect do
          subject(file, research_project.id, primer)
        end
          .to have_enqueued_job.with(
            data.to_json,
            [nil, nil, csv_barcode1, csv_barcode2],
            { csv_barcode1 => 999, csv_barcode2 => 888 },
            research_project_id: research_project.id, primer: primer
          )
      end

      it 'returns valid' do
        results = subject(file, research_project.id, primer)
        expect(results.valid?).to eq(true)
      end
    end

    context 'when barcodes in CSV do not match samples in the database' do
      before(:each) do
        create(:sample, barcode: 'K9999-A1', status: 'approved')
      end

      it 'does not add ImportCsvQueueAsvJob to queue' do
        expect do
          subject(file, research_project.id, primer)
        end
          .to_not have_enqueued_job(ImportCsvQueueAsvJob)
      end

      it 'returns error message' do
        results = subject(file, research_project.id, primer)
        message = "#{csv_barcode1}, #{csv_barcode2} not in the database"
        expect(results.valid?).to eq(false)
        expect(results.errors).to eq(message)
      end
    end
  end

  describe('#queue_asv_job') do
    include ActiveJob::TestHelper

    before(:each) do
      project = create(:field_project, name: 'unknown')
      stub_const('FieldProject::DEFAULT_PROJECT', project)
    end

    def subject
      asv_attributes =
        { research_project_id: research_project.id, primer: primer }
      barcodes = dummy_class.convert_header_row_to_barcodes(data)
      samples_data =
        dummy_class.find_samples_from_barcodes(barcodes)[:valid_data]
      dummy_class.queue_asv_job(data.to_json, barcodes, samples_data,
                                asv_attributes)
    end

    let(:csv) { './spec/fixtures/import_csv/dna_results_tabs.csv' }
    let(:file) { fixture_file_upload(csv, 'text/csv') }
    let(:research_project) { create(:research_project) }
    let(:primer) { '12S' }
    let(:data) { CSV.read(file.path, headers: true, col_sep: "\t") }
    let(:csv_barcode1) { 'K0001-LA-S1' }

    context 'when matching taxon does not exist' do
      let!(:cal_taxon) do
        create(
          :cal_taxon,
          clean_taxonomy_string: 'Foo',
          taxon_rank: 'phylum',
          normalized: true
        )
      end

      it 'does not add ImportCsvCreateAsvJob to queue' do
        expect do
          subject
        end
          .to_not have_enqueued_job(ImportCsvCreateAsvJob)
      end

      it 'does not add ImportCsvCreateResearchProjectSourceJob to queue' do
        expect do
          subject
        end
          .to_not have_enqueued_job(ImportCsvCreateResearchProjectSourceJob)
      end
    end

    context 'when matching taxon does exist with no reads' do
      let!(:cal_taxon) do
        create(
          :cal_taxon,
          clean_taxonomy_string: data[0]['sum.taxonomy'],
          taxon_rank: 'family',
          normalized: true
        )
      end

      it 'does not add ImportCsvCreateAsvJob to queue' do
        expect do
          subject
        end
          .to_not have_enqueued_job(ImportCsvCreateAsvJob)
      end

      it 'does not add ImportCsvCreateResearchProjectSourceJob to queue' do
        expect do
          subject
        end
          .to_not have_enqueued_job(ImportCsvCreateResearchProjectSourceJob)
      end
    end

    context 'when matching taxon does exist with reads' do
      let!(:cal_taxon) do
        create(
          :cal_taxon,
          clean_taxonomy_string: data[1]['sum.taxonomy'],
          taxon_rank: 'genus',
          normalized: true
        )
      end

      it 'adds ImportCsvCreateAsvJob to queue' do
        expect do
          subject
        end
          .to have_enqueued_job(ImportCsvCreateAsvJob).exactly(2).times
      end

      it 'does add ImportCsvCreateResearchProjectSourceJob to queue' do
        expect do
          subject
        end
          .to have_enqueued_job(ImportCsvCreateResearchProjectSourceJob)
          .exactly(2).times
      end
    end
  end

  describe '#convert_header_row_to_barcodes' do
    def subject(data)
      dummy_class.convert_header_row_to_barcodes(data)
    end

    let(:csv_barcode1) { 'K0001-LA-S1' }
    let(:csv_barcode2) { 'K0001-LA-S2' }

    it 'converts the CSV headers into barcodes' do
      csv = './spec/fixtures/import_csv/dna_results_tabs.csv'
      file = fixture_file_upload(csv, 'text/csv')
      delimiter = "\t"
      data = CSV.read(file.path, headers: true, col_sep: delimiter)

      expect(subject(data)).to eq([nil, nil, csv_barcode1, csv_barcode2])
    end
  end
end
