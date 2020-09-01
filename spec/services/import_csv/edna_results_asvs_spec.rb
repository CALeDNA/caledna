# frozen_string_literal: true

require 'rails_helper'

describe ImportCsv::EdnaResultsAsvs do
  before do
    website = create(:website, name: 'foo')
    allow(Website).to receive(:caledna).and_return(website)
    allow(Website).to receive(:la_river).and_return(website)
  end

  let(:dummy_class) { Class.new { extend ImportCsv::EdnaResultsAsvs } }

  describe('#import_csv') do
    include ActiveJob::TestHelper

    before(:each) do
      create(:field_project, name: 'unknown')
    end

    def subject(file, research_project_id, primer)
      dummy_class.import_csv(file, research_project_id, primer)
    end

    let(:csv) { './spec/fixtures/import_csv/dna_results_tabs.csv' }
    let(:file) { fixture_file_upload(csv, 'text/csv') }
    let(:research_project) { create(:research_project) }
    let(:primer) { 1 }
    let(:csv_barcode1) { 'K0001-LA-S1' }
    let(:csv_barcode2) { 'K0001-LA-S2' }

    context 'when CSV contains duplicate barcodes' do
      let(:csv) { './spec/fixtures/import_csv/dna_results_tabs_dup.csv' }

      it 'and samples are in the database, it returns error message' do
        create(:sample, barcode: csv_barcode1, status: 'approved', id: 999)
        create(:sample, barcode: csv_barcode2, status: 'approved', id: 888)

        results = subject(file, research_project.id, primer)
        message = 'K0001A2.S1.L001 listed multiple times'

        expect(results.valid?).to eq(false)
        expect(results.errors).to eq(message)
      end

      it 'and samples are not in the database, it returns error message' do
        create(:sample, barcode: csv_barcode1, status: 'approved', id: 999)
        # create(:sample, barcode: csv_barcode2, status: 'approved', id: 888)

        results = subject(file, research_project.id, primer)
        message = "#{csv_barcode2} not in the database"

        expect(results.valid?).to eq(false)
        expect(results.errors).to eq(message)
      end
    end

    context 'when research project and primer have been imported' do
      it 'returns error message' do
        primer = create(:primer, id: 10)
        project = create(:research_project, id: 1)
        create(:sample_primer, research_project: project, primer: primer,
                               sample: create(:sample))

        results = subject(file, project, primer.id)
        message = 'research project have already been imported.'

        expect(results.valid?).to eq(false)
        expect(results.errors).to end_with(message)
      end
    end

    context 'when csv does not start with sum taxonomy' do
      it 'returns error if sum taxonomy exists' do
        create(:sample, barcode: csv_barcode1, status: 'approved', id: 999)
        create(:sample, barcode: csv_barcode2, status: 'approved', id: 888)
        csv = './spec/fixtures/import_csv/dna_results_id_first_column.csv'
        file = fixture_file_upload(csv, 'text/csv')

        results = subject(file, research_project, primer)
        message = '"sum.taxonomy" must be first column'

        expect(results.valid?).to eq(false)
        expect(results.errors).to eq(message)
      end

      it 'returns error if sum taxonomy does not exists' do
        create(:sample, barcode: csv_barcode1, status: 'approved', id: 999)
        create(:sample, barcode: csv_barcode2, status: 'approved', id: 888)
        csv = './spec/fixtures/import_csv/dna_results_no_sum_taxonomy.csv'
        file = fixture_file_upload(csv, 'text/csv')

        results = subject(file, research_project, primer)
        message = '"sum.taxonomy" must be first column'

        expect(results.valid?).to eq(false)
        expect(results.errors).to eq(message)
      end
    end

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

      it 'pass correct agruments to ImportCsvQueueAsvJob' do
        delimiter = "\t"
        data = CSV.read(file.path, headers: true, col_sep: delimiter)

        expect do
          subject(file, research_project.id, primer)
        end
          .to have_enqueued_job.with(
            data.to_json,
            [nil, nil, csv_barcode1, csv_barcode2, nil, nil],
            { csv_barcode1 => 999, csv_barcode2 => 888 },
            research_project_id: research_project.id, primer_id: primer
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
          .to have_enqueued_job(ImportCsvQueueAsvJob).exactly(0).times
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

    let(:csv) { './spec/fixtures/import_csv/dna_results_tabs.csv' }
    let(:file) { fixture_file_upload(csv, 'text/csv') }
    let(:research_project) { create(:research_project, id: project_id) }
    let(:primer) { create(:primer, id: primer_id) }
    let(:data) { CSV.read(file.path, headers: true, col_sep: "\t") }
    let(:csv_barcode1) { 'K0001-LA-S1' }
    let(:taxon_id1) { 1 }
    let(:taxon_id2) { 2 }
    let(:taxon_id3) { 3 }
    let(:sample_id1) { 100 }
    let(:sample_id2) { 200 }
    let(:project_id) { 500 }
    let(:primer_id) { 1000 }

    before(:each) do
      create(:field_project, name: 'unknown')
      create(:sample, :approved, barcode: 'K0001-LA-S1', id: sample_id1)
      create(:sample, :approved, barcode: 'K0001-LA-S2', id: sample_id2)
    end

    def subject
      asv_attributes =
        { research_project_id: research_project.id, primer_id: primer.id }
      barcodes = dummy_class.convert_header_row_to_barcodes(data)
      samples_data =
        dummy_class.find_samples_from_barcodes(barcodes)[:valid_data]

      dummy_class.queue_asv_job(data.to_json, barcodes, samples_data,
                                asv_attributes)
    end

    # rubocop:disable Metrics/MethodLength
    def create_taxa
      create(
        :result_taxon,
        taxon_id: taxon_id1,
        taxon_rank: 'family',
        clean_taxonomy_string: 'Phylum;Class;Order;Family;;'
      )
      create(
        :result_taxon,
        taxon_id: taxon_id2,
        taxon_rank: 'genus',
        clean_taxonomy_string: 'Phylum;Class;Order;Family;Genus;'
      )
      create(
        :result_taxon,
        taxon_id: taxon_id3,
        taxon_rank: 'species',
        clean_taxonomy_string: 'Phylum;Class;Order;Family;Genus;Genus species'
      )
    end
    # rubocop:enable Metrics/MethodLength

    it 'adds ImportCsvFirstOrCreateSamplePrimerJob to queue' do
      expect do
        subject
      end
        .to have_enqueued_job(ImportCsvFirstOrCreateSamplePrimerJob)
        .exactly(2).times
    end

    it 'passes arguements to ImportCsvFirstOrCreateSamplePrimerJob' do
      arguements = {
        sample_id: sample_id1,
        research_project_id: project_id,
        primer_id: primer_id
      }

      expect { subject }
        .to have_enqueued_job.with(arguements).exactly(1).times
    end

    it 'passes arguements to ImportCsvFirstOrCreateSamplePrimerJob' do
      arguements = {
        sample_id: sample_id2,
        research_project_id: project_id,
        primer_id: primer_id
      }

      expect { subject }
        .to have_enqueued_job.with(arguements).exactly(1).times
    end

    it 'adds ImportCsvUpdateSampleStatusJob to queue' do
      expect do
        subject
      end
        .to have_enqueued_job(ImportCsvUpdateSampleStatusJob).exactly(2).times
    end

    it 'passes arguements to ImportCsvUpdateSampleStatusJob' do
      arguements = sample_id1

      expect { subject }
        .to have_enqueued_job.with(arguements).exactly(1).times
    end

    it 'passes arguements to ImportCsvUpdateSampleStatusJob' do
      arguements = sample_id2

      expect { subject }
        .to have_enqueued_job.with(arguements).exactly(1).times
    end

    it 'adds ImportCsvFirstOrCreateResearchProjSourceJob to queue' do
      expect do
        subject
      end
        .to have_enqueued_job(ImportCsvFirstOrCreateResearchProjSourceJob)
        .exactly(2).times
    end

    it 'pass correct agruments to ' \
    'ImportCsvFirstOrCreateResearchProjSourceJob' do
      expect do
        subject
      end
        .to have_enqueued_job.with(sample_id1, 'Sample', project_id)
                             .exactly(1).times
    end

    it 'pass correct agruments to ' \
    'ImportCsvFirstOrCreateResearchProjSourceJob' do
      expect do
        subject
      end
        .to have_enqueued_job.with(sample_id2, 'Sample', project_id)
                             .exactly(1).times
    end

    context 'when matching ResultTaxon does not exist' do
      it 'creates a ImportCsvCreateUnmatchedResultJob' do
        create_taxa
        ResultTaxon.first.update(clean_taxonomy_string: 'Bad;;;;;taxon')

        expect do
          subject
        end
          .to have_enqueued_job(ImportCsvCreateUnmatchedResultJob)
          .exactly(1).times
      end

      it 'pass correct agruments to ImportCsvCreateUnmatchedResultJob' do
        create_taxa
        ResultTaxon.first.update(clean_taxonomy_string: 'Bad;;;;;taxon')

        expect do
          subject
        end
          .to have_enqueued_job.with(
            'Phylum;Class;Order;Family;;',
            research_project_id: project_id,
            primer_id: primer_id
          ).exactly(1).times
      end

      it 'does not add ImportCsvCreateAsvJob to queue' do
        expect do
          subject
        end
          .to have_enqueued_job(ImportCsvCreateAsvJob).exactly(0).times
      end
    end

    context 'when matching taxon does exist with reads' do
      before(:each) do
        create_taxa
      end

      it 'does not add ImportCsvCreateUnmatchedResultJob to queue' do
        expect do
          subject
        end
          .to have_enqueued_job(ImportCsvCreateUnmatchedResultJob)
          .exactly(0).times
      end

      it 'adds ImportCsvCreateAsvJob to queue' do
        expect do
          subject
        end
          .to have_enqueued_job(ImportCsvCreateAsvJob).exactly(2).times
      end

      it 'pass correct agruments to ImportCsvCreateAsvJob' do
        expect do
          subject
        end
          .to have_enqueued_job.with(
            research_project_id: project_id, primer_id: primer_id,
            taxon_id: taxon_id2, sample_id: sample_id1, count: 2,
            taxonomy_string: 'Phylum;Class;Order;Family;Genus;'
          ).exactly(1).times
      end

      it 'pass correct agruments to ImportCsvCreateAsvJob' do
        expect do
          subject
        end
          .to have_enqueued_job.with(
            research_project_id: project_id, primer_id: primer_id,
            taxon_id: taxon_id2, sample_id: sample_id2, count: 4,
            taxonomy_string: 'Phylum;Class;Order;Family;Genus;'
          ).exactly(1).times
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

      expect(subject(data))
        .to eq([nil, nil, csv_barcode1, csv_barcode2, nil, nil])
    end
  end
end
