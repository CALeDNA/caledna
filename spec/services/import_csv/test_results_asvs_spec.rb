# frozen_string_literal: true

require 'rails_helper'

describe ImportCsv::TestResultsAsvs do
  let(:dummy_class) { Class.new { extend ImportCsv::TestResultsAsvs } }

  describe '#convert_header_to_barcode' do
    def subject(header)
      dummy_class.convert_header_to_barcode(header)
    end

    it 'converts kit.number header' do
      header = 'X16S_K0078.C2.S59.L001'

      expect(subject(header)).to eq('K0078-LC-S2')
    end

    it 'converts K_L_S_ header' do
      headers = [
        ['X16S_K1LAS1.S18.L001', 'K0001-LA-S1'],
        ['X16S_K12LAS1.S18.L001', 'K0012-LA-S1'],
        ['X16S_K123LAS1.S18.L001', 'K0123-LA-S1'],
        ['X16S_K1234LAS1.S18.L001', 'K1234-LA-S1']
      ]

      headers.each do |header|
        expect(subject(header.first)).to eq(header.second)
      end
    end

    it 'converts X12S_K0723_A1.10.S10.L001' do
      headers = [
        ['X12S_K0001_A1.01.S01.L001', 'K0001-A1'],
        ['K0001_A1.01.S01.L001', 'K0001-A1']
      ]

      headers.each do |header|
        expect(subject(header.first)).to eq(header.second)
      end
    end

    it 'converts water samples' do
      headers = [
        ['X12S_MWWS_A0.01.S01.L001', 'MWWS-A0'],
        ['ASWS_A0.01.S01.L001', 'ASWS-A0']
      ]

      headers.each do |header|
        expect(subject(header.first)).to eq(header.second)
      end
    end

    it 'converts K_S_L_ header' do
      headers = [
        ['X16S_K1S1LA.S18.L001', 'K0001-LA-S1'],
        ['X16S_K12S1LA.S18.L001', 'K0012-LA-S1'],
        ['X16S_K123S1LA.S18.L001', 'K0123-LA-S1'],
        ['X16S_K1234S1LA.S18.L001', 'K1234-LA-S1']
      ]

      headers.each do |header|
        expect(subject(header.first)).to eq(header.second)
      end
    end

    it 'converts K_S_L_R_ header' do
      headers = [
        ['X16S_K1S1LAR1.S18.L001', 'K0001-LA-S1-R1'],
        ['X16S_K12S1LAR1.S18.L001', 'K0012-LA-S1-R1'],
        ['X16S_K123S1LAR1.S18.L001', 'K0123-LA-S1-R1'],
        ['X16S_K1234S1LAR1.S18.L001', 'K1234-LA-S1-R1']
      ]

      headers.each do |header|
        expect(subject(header.first)).to eq(header.second)
      end
    end

    it 'converts K_LS header' do
      headers = [
        ['X16S_K1A1.S18.L001', 'K0001-LA-S1'],
        ['X16S_K12A1.S18.L001', 'K0012-LA-S1'],
        ['X16S_K123A1.S18.L001', 'K0123-LA-S1'],
        ['X16S_K1234A1.S18.L001', 'K1234-LA-S1']
      ]

      headers.each do |header|
        expect(subject(header.first)).to eq(header.second)
      end
    end

    it 'converts _LS header' do
      headers = [
        ['X16S_1A1.S18.L001', 'K0001-LA-S1'],
        ['X16S_12A1.S18.L001', 'K0012-LA-S1'],
        ['X16S_123A1.S18.L001', 'K0123-LA-S1'],
        ['X16S_1234A1.S18.L001', 'K1234-LA-S1']
      ]

      headers.each do |header|
        expect(subject(header.first)).to eq(header.second)
      end
    end

    it 'converts header without primers' do
      headers = [
        ['K1A1.S18.L001', 'K0001-LA-S1'],
        ['K12A1.S18.L001', 'K0012-LA-S1'],
        ['K123A1.S18.L001', 'K0123-LA-S1'],
        ['K1234A1.S18.L001', 'K1234-LA-S1']
      ]

      headers.each do |header|
        expect(subject(header.first)).to eq(header.second)
      end
    end

    it 'converts abbreviated K_LS header' do
      headers =  [
        ['K1B1', 'K0001-LB-S1'],
        ['K12B1', 'K0012-LB-S1'],
        ['K123B1', 'K0123-LB-S1'],
        ['K1234B1', 'K1234-LB-S1']
      ]

      headers.each do |header|
        expect(subject(header.first)).to eq(header.second)
      end
    end

    it 'converts abbreviated X_LS header' do
      headers =  [
        ['X1B1', 'K0001-LB-S1'],
        ['X12B1', 'K0012-LB-S1'],
        ['X123B1', 'K0123-LB-S1'],
        ['X1234B1', 'K1234-LB-S1']
      ]

      headers.each do |header|
        expect(subject(header.first)).to eq(header.second)
      end
    end

    it 'converts abbreviated _LS header' do
      headers =  [
        ['1B1', 'K0001-LB-S1'],
        ['12B1', 'K0012-LB-S1'],
        ['123B1', 'K0123-LB-S1'],
        ['1234B1', 'K1234-LB-S1']
      ]

      headers.each do |header|
        expect(subject(header.first)).to eq(header.second)
      end
    end

    it 'converts abbreviated PP_LS header' do
      headers =  [
        ['PP1B1', 'K0001-LB-S1'],
        ['PP12B1', 'K0012-LB-S1'],
        ['PP123B1', 'K0123-LB-S1'],
        ['PP1234B1', 'K1234-LB-S1']
      ]

      headers.each do |header|
        expect(subject(header.first)).to eq(header.second)
      end
    end

    it 'returns nil for "blank" samples' do
      headers = [
        'K0401.blank.S135.L001', 'X16s_K0001Blank.S1.L001', 'forestpcrBLANK',
        'X16S_ShrubBlank1'
      ]
      headers.each do |header|
        expect(subject(header)).to eq(nil)
      end
    end

    it 'returns nil for "neg" samples' do
      headers = [
        'K0401.extneg.S135.L001', 'X16s_K0001Neg.S1.L001', 'forestpcrNEG',
        'X16S_neg'
      ]

      headers.each do |header|
        expect(subject(header)).to eq(nil)
      end
    end

    it 'returns nil for invalid barcode' do
      header = 'PITS_forest.S96.L001'

      expect(subject(header)).to eq(nil)
    end
  end

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
      research_project_id = research_project.id
      extraction_type = create(:extraction_type)
      extraction_type_id = extraction_type.id

      first_row = data.first
      sample_cells = first_row.headers[1..first_row.headers.size]
      extractions = dummy_class.get_extractions_from_headers(
        sample_cells, research_project_id, extraction_type_id
      )

      expect do
        subject(
          file, research_project.id, extraction_type.id, primer
        )
      end
        .to have_enqueued_job.with(data.to_json, sample_cells, extractions,
                                   primer)
    end

    it 'returns valid' do
      expect(
        subject(file, research_project.id, extraction_type.id, primer).valid?
      )
        .to eq(true)
    end
  end

  describe('#queue_asv_job') do
    include ActiveJob::TestHelper

    before(:each) do
      project = create(:field_project, name: 'unknown')
      stub_const('FieldProject::DEFAULT_PROJECT', project)
    end

    def subject(data, sample_cells, extractions, primer)
      dummy_class.queue_asv_job(data, sample_cells, extractions, primer)
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

    context 'when matching sample does not exists' do
      it 'creates sample & extraction' do
        expect do
          subject(
            data.to_json, sample_cells, extractions, primer
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
        create(:sample, barcode: 'K0001-LA-S1')
        create(:sample, barcode: 'forest')

        expect do
          subject(
            data.to_json, sample_cells, extractions, primer
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
            data.to_json, sample_cells, extractions, primer
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
            data.to_json, sample_cells, extractions, primer
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
            data.to_json, sample_cells, extractions, primer
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
            data.to_json, sample_cells, extractions, primer
          )
        end
          .to have_enqueued_job(ImportCsvCreateAsvJob)
      end
    end
  end
end
