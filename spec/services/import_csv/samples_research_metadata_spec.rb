# frozen_string_literal: true

require 'rails_helper'

describe ImportCsv::SamplesResearchMetadata do
  let(:dummy_class) { Class.new { extend ImportCsv::SamplesResearchMetadata } }

  describe('#import_csv') do
    include ActiveJob::TestHelper

    def subject(file, research_project_id)
      dummy_class.import_csv(file, research_project_id)
    end

    let(:csv) { './spec/fixtures/import_csv/samples_metadata.csv' }
    let(:file) { fixture_file_upload(csv, 'text/csv') }
    let(:research_project_id) do
      create(:research_project, name: 'foo',
                                research_project_id: research_project_id)
    end
    let(:barcode1) { 'K9999-A1' }
    let(:barcode2) { 'K9999-A2' }
    let(:research_project_id) { 100 }

    context 'when CSV does not have sum.taxonomy column' do
      it 'returns an error' do
        csv = './spec/fixtures/import_csv/samples_metadata_bad.csv'
        file = fixture_file_upload(csv, 'text/csv')

        results = subject(file, research_project_id)
        expect(results.valid?).to eq(false)
        message =
          'The column with the samples names must be called "sum.taxonomy"'
        expect(results.errors).to eq(message)
      end
    end

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
      before(:each) do
        create(:sample, barcode: barcode1)
        create(:sample, barcode: barcode2)
      end

      it 'enqueues ImportCsvCreateOrUpdateResearchProjSourceJob' do
        expect { subject(file, research_project_id) }
          .to have_enqueued_job(ImportCsvCreateOrUpdateResearchProjSourceJob)
          .exactly(2).times
      end

      it 'passes correct as arguement to ' \
        'ImportCsvCreateOrUpdateResearchProjSourceJob' do

        attr1 = { 'sum.taxonomy' => barcode1, 'field1' => 'a',
                  'field2' => 'b' }
        attr2 = { 'sum.taxonomy' => barcode2, 'field1' => 'c',
                  'field2' => 'd' }

        expect { subject(file, research_project_id) }
          .to have_enqueued_job
          .with(attr1, barcode1, research_project_id).exactly(1).times
          .with(attr2, barcode2, research_project_id).exactly(1).times
      end
    end
  end

  describe('#create_or_update_research_proj_sources') do
    def subject(row, barcode, research_project_id)
      dummy_class.create_or_update_research_proj_source(
        row, barcode, research_project_id
      )
    end

    let(:research_project_id) { create(:research_project, name: 'foo').id }
    let(:barcode1) { 'K9999-A1' }
    let(:barcode2) { 'K9999-A2' }

    context 'when there are no samples with a given barcode' do
      it 'does not create ResearchProjectSource' do
        row = { 'sum.taxonomy' => barcode1, 'attr1' => 'a' }

        expect { subject(row, barcode1, research_project_id) }
          .to change { ResearchProjectSource.count }.by(0)
      end
    end

    context 'when there are unapproved samples with a given barcode' do
      it 'does not create ResearchProjectSource' do
        create(:sample, status_cd: 'rejected')
        row = { 'sum.taxonomy' => barcode1, 'attr1' => 'a' }

        expect { subject(row, barcode1, research_project_id) }
          .to change { ResearchProjectSource.count }.by(0)
      end
    end

    context 'when there are approved samples with a given barcode' do
      let!(:sample1) { create(:sample, :approved, barcode: barcode1) }
      let!(:sample2) { create(:sample, :approved, barcode: barcode2) }
      let(:row1) do
        { 'sum.taxonomy' => barcode1, 'field1' => 'a', 'field2' => 'b' }
      end

      context 'and ResearchProjectSource does not exist' do
        it 'creates ResearchProjectSource' do
          expect { subject(row1, barcode1, research_project_id) }
            .to change { ResearchProjectSource.count }.by(1)
        end

        it 'creates ResearchProjectSource using csv data' do
          subject(row1, barcode1, research_project_id)
          source = ResearchProjectSource.first

          expect(source.sourceable).to eq(sample1)
          expect(source.research_project_id).to eq(research_project_id)
          expect(source.metadata).to eq('field1' => 'a', 'field2' => 'b')
        end
      end

      context 'and ResearchProjectSource already exists' do
        let!(:source1) do
          create(:research_project_source,
                 sourceable: sample1, research_project_id: research_project_id,
                 metadata: { old: 1 })
        end
        let!(:source2) do
          create(:research_project_source,
                 sourceable: sample2, research_project_id: research_project_id,
                 metadata: {})
        end

        it 'does not create ResearchProjectSource' do
          expect { subject(row1, barcode1, research_project_id) }
            .to change { ResearchProjectSource.count }.by(0)
        end

        it 'does not change the existing research_project_id' do
          expect { subject(row1, barcode1, research_project_id) }
            .to_not(change { source1.reload.research_project_id })
        end

        it 'does not change the existing sourceable_id' do
          expect { subject(row1, barcode1, research_project_id) }
            .to_not(change { source1.reload.sourceable_id })
        end

        it 'overwrites the existing metadata' do
          expect { subject(row1, barcode1, research_project_id) }
            .to change { source1.reload.metadata }
            .from('old' => 1)
            .to('field1' => 'a', 'field2' => 'b')
        end

        it 'overwrites the default metadata' do
          row2 =
            { 'sum.taxonomy' => barcode2, 'field1' => 'a', 'field2' => 'b' }

          expect { subject(row2, barcode2, research_project_id) }
            .to change { source2.reload.metadata }
            .from({})
            .to('field1' => 'a', 'field2' => 'b')
        end
      end
    end
  end
end
