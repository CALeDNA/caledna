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

    def subject(file, research_project_id, extraction_type_id, primer)
      dummy_class.import_csv(file, research_project_id, extraction_type_id,
                             primer)
    end

    let(:csv) { './spec/fixtures/import_csv/dna_results_tabs.csv' }
    let(:file) { fixture_file_upload(csv, 'text/csv') }
    let(:extraction_type) { create(:extraction_type) }
    let(:research_project) { create(:research_project) }
    let(:primer) { '12S' }
    let(:csv_barcode1) { 'K0001-LA-S1' }

    context 'when barcodes in CSV match samples in the database' do
      before(:each) do
        create(:sample, barcode: csv_barcode1, status: 'approved')
      end

      it 'adds ImportCsvQueueAsvJob to queue' do
        expect do
          subject(
            file, research_project.id, extraction_type.id, primer
          )
        end
          .to have_enqueued_job(ImportCsvQueueAsvJob)
      end

      it 'adds pass correct agruments to ImportCsvQueueAsvJob' do
        delimiter = "\t"
        data = CSV.read(file.path, headers: true, col_sep: delimiter)
        extraction_type = create(:extraction_type)

        expect do
          subject(
            file, research_project.id, extraction_type.id, primer
          )
        end
          .to have_enqueued_job.with(data.to_json, research_project.id,
                                     extraction_type.id, primer)
      end

      it 'returns valid' do
        results = subject(file, research_project.id, extraction_type.id, primer)
        expect(results.valid?).to eq(true)
      end
    end

    context 'when barcodes in CSV do not match samples in the database' do
      before(:each) do
        create(:sample, barcode: 'K9999-A1', status: 'approved')
      end

      it 'does not add ImportCsvQueueAsvJob to queue' do
        expect do
          subject(file, research_project.id, extraction_type.id, primer)
        end
          .to_not have_enqueued_job(ImportCsvQueueAsvJob)
      end

      it 'returns error message' do
        results = subject(file, research_project.id, extraction_type.id, primer)
        message = "#{csv_barcode1} not in the database"
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

    def subject(data, research_project_id, extraction_type_id, primer)
      dummy_class.queue_asv_job(data, research_project_id, extraction_type_id,
                                primer)
    end

    let(:csv) { './spec/fixtures/import_csv/dna_results_tabs.csv' }
    let(:file) { fixture_file_upload(csv, 'text/csv') }
    let(:extraction_type) { create(:extraction_type) }
    let(:research_project) { create(:research_project) }
    let(:primer) { '12S' }
    let(:delimiter) { "\t" }
    let(:data) { CSV.read(file.path, headers: true, col_sep: delimiter) }
    let(:sample_cells) do
      first_row = data.first
      first_row.headers[1..first_row.headers.size]
    end
    let(:extractions) do
      dummy_class.get_extractions_from_headers(
        sample_cells, research_project.id, extraction_type.id
      )
    end
    let(:csv_barcode1) { 'K0001-LA-S1' }

    context 'when matching sample does not exists' do
      it 'creates sample & extraction' do
        expect do
          subject(
            data.to_json, research_project.id, extraction_type.id, primer
          )
        end
          .to change { Sample.count }
          .by(1)
          .and change { Extraction.count }
          .by(1)
      end
    end

    context 'when matching extraction does not exists' do
      it 'creates extraction' do
        create(:sample, barcode: csv_barcode1)
        create(:sample, barcode: 'forest')

        expect do
          subject(
            data.to_json, research_project.id, extraction_type.id, primer
          )
        end
          .to change { Sample.count }
          .by(0)
          .and change { Extraction.count }
          .by(1)
      end
    end

    context 'when matching sample exists' do
      it 'does not create sample or extraction' do
        sample = create(:sample, barcode: 'K0001-LA-S1')
        sample2 = create(:sample, barcode: 'forest')
        create(:extraction, sample: sample, extraction_type: extraction_type)
        create(:extraction, sample: sample2, extraction_type: extraction_type)

        expect do
          subject(
            data.to_json, research_project.id, extraction_type.id, primer
          )
        end
          .to change { Sample.count }
          .by(0)
          .and change { Extraction.count }
          .by(0)
      end
    end

    context 'when matching taxon does not exist' do
      before(:each) do
        create(
          :cal_taxon,
          original_taxonomy_phylum: 'Foo',
          taxonRank: 'phylum',
          normalized: true
        )
      end

      it 'does not add ImportCsvCreateAsvJob to queue' do
        expect do
          subject(
            data.to_json, research_project.id, extraction_type.id, primer
          )
        end
          .to_not have_enqueued_job(ImportCsvCreateAsvJob)
      end
    end

    context 'when matching taxon does exist with no reads' do
      before(:each) do
        create(
          :cal_taxon,
          original_taxonomy_phylum: data[0]['sum.taxonomy'],
          taxonRank: 'family',
          normalized: true
        )
      end

      it 'does not add ImportCsvCreateAsvJob to queue' do
        expect do
          subject(
            data.to_json, research_project.id, extraction_type.id, primer
          )
        end
          .to_not have_enqueued_job(ImportCsvCreateAsvJob)
      end
    end

    context 'when matching taxon does exist with reads' do
      before(:each) do
        create(
          :cal_taxon,
          original_taxonomy_phylum: data[1]['sum.taxonomy'],
          taxonRank: 'genus',
          normalized: true
        )
      end

      it 'adds ImportCsvCreateAsvJob to queue' do
        expect do
          subject(
            data.to_json, research_project.id, extraction_type.id, primer
          )
        end
          .to have_enqueued_job(ImportCsvCreateAsvJob)
      end
    end
  end
end
