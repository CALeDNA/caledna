# frozen_string_literal: true

require 'rails_helper'
require 'csv'

describe ImportCsv::DnaResults do
  let(:dummy_class) { Class.new { extend ImportCsv::ProcessingExtractions } }

  describe '#find_researcher' do
    def subject(name)
      dummy_class.find_researcher(name)
    end

    it 'returns nil if name is "pending"' do
      name = 'PenDing'
      expect(subject(name)).to eq(nil)
    end

    context 'given name matches existing researcher' do
      it 'returns existing researcher' do
        name = 'Jane'
        researcher = create(:researcher, username: name)

        expect(subject(name)).to eq(researcher)
      end
    end

    context 'given name does not match existing researcher' do
      it 'creates new researcher' do
        name = 'Jane'
        create(:researcher, username: 'Jill')

        expect { subject(name) }.to change { Researcher.count }.by(1)
      end

      it 'returns newly created researcher' do
        name = 'Jane'
        create(:researcher, username: 'Jill')

        expect(subject(name)).to be_kind_of(Researcher)
        expect(subject(name).username).to eq(name)
      end
    end
  end

  describe('#process_boolean') do
    def subject(string)
      dummy_class.process_boolean(string)
    end

    it 'returns true if input is "yes"' do
      input = 'YeS'

      expect(subject(input)).to eq(true)
    end

    it 'returns true if input is "no"' do
      input = 'nO'

      expect(subject(input)).to eq(false)
    end

    it 'returns nil if input is random text' do
      input = 'abc'

      expect(subject(input)).to eq(nil)
    end
  end

  describe '#process_keyword_boolean' do
    def subject(string, keyword)
      dummy_class.process_keyword_boolean(string, keyword)
    end

    it 'returns true if input is "yes"' do
      keyword = 'abc'
      input = 'YeS'

      expect(subject(input, keyword)).to eq(true)
    end

    it 'returns true if input matches keyword' do
      keyword = 'abc'
      input = keyword

      expect(subject(input, keyword)).to eq(true)
    end

    it 'returns false if input is "no"' do
      keyword = 'abc'
      input = 'nO'

      expect(subject(input, keyword)).to eq(false)
    end

    it 'returns nil otherwise' do
      keyword = 'abc'
      input = 'cde'

      expect(subject(input, keyword)).to eq(nil)
    end
  end

  describe('#convert_date') do
    def subject(string)
      dummy_class.convert_date(string)
    end

    it 'returns nil if input is "pending"' do
      input = 'pending'

      expect(subject(input)).to eq(nil)
    end

    it 'returns nil if input is empty string' do
      input = nil

      expect(subject(input)).to eq(nil)
    end

    it 'returns "July 1" and year when passed in "Summer" and year' do
      input = 'SummEr 2018'
      expected = Time.parse('July 01, 2018')

      expect(subject(input)).to eq(expected)
    end

    it 'returns a date when given day, month, year' do
      input = '11-Apr-18'
      expected = Time.parse('April 11, 2018')

      expect(subject(input)).to eq(expected)
    end

    it 'returns a date when given a month and year' do
      input = 'Apr-18'
      expected = Time.parse('April 1, 2018')

      expect(subject(input)).to eq(expected)
    end

    it 'raises an error if given invalid date' do
      input = 'abc'

      expect { subject(input) }.to raise_error(ArgumentError, /no time info/)
    end
  end

  describe '#form_barcode' do
    def subject(string)
      dummy_class.form_barcode(string)
    end

    it 'returns a barcode when given a valid kit number with spaces' do
      string = 'K0001 B1'

      expect(subject(string)).to eq('K0001-LB-S1')
    end

    it 'returns a barcode when given a valid kit number w/o spaces' do
      string = 'K0001B1'

      expect(subject(string)).to eq('K0001-LB-S1')
    end

    it 'otherwise returns the original string' do
      string = 'abc'

      expect(subject(string)).to eq(string)
    end
  end

  describe('#import_csv') do
    include ActiveJob::TestHelper

    before(:each) do
      project = create(:field_data_project, name: 'unknown')
      stub_const('FieldDataProject::DEFAULT_PROJECT', project)
    end

    def subject(file, research_project_id, extraction_type_id)
      dummy_class.import_csv(file, research_project_id, extraction_type_id)
    end

    let(:csv) { './spec/fixtures/import_csv/processing_extraction.csv' }
    let(:file) { fixture_file_upload(csv, 'text/csv') }
    let(:extraction_type) { create(:extraction_type) }
    let(:research_project) { create(:research_project) }

    it 'adds ImportCsvCreateResearchProjectExtractionJob to queue' do
      create(:researcher, username: 'user1')

      expect { subject(file, research_project.id, extraction_type.id) }
        .to have_enqueued_job(ImportCsvCreateResearchProjectExtractionJob)
    end

    it 'adds ImportCsvUpdateExtractionDetailsJob to queue' do
      create(:researcher, username: 'user1')

      expect { subject(file, research_project.id, extraction_type.id) }
        .to have_enqueued_job(ImportCsvUpdateExtractionDetailsJob)
    end

    context 'when matching sample does not exists' do
      it 'creates sample & extraction' do
        create(:researcher, username: 'user1')

        expect { subject(file, research_project.id, extraction_type.id) }
          .to change { Sample.count }
          .by(1)
          .and change { Extraction.count }
          .by(1)
      end
    end

    context 'when matching extraction does not exists' do
      it 'creates extraction' do
        create(:researcher, username: 'user1')
        create(:sample, barcode: 'K0001-LA-S1')

        expect { subject(file, research_project.id, extraction_type.id) }
          .to change { Sample.count }
          .by(0)
          .and change { Extraction.count }
          .by(1)
      end
    end

    context 'when matching sample exists' do
      it 'does not create sample or extraction' do
        create(:researcher, username: 'user1')
        sample = create(:sample, barcode: 'K0001-LA-S1')
        create(:extraction, sample: sample, extraction_type: extraction_type)

        expect { subject(file, research_project.id, extraction_type.id) }
          .to change { Sample.count }
          .by(0)
          .and change { Extraction.count }
          .by(0)
      end
    end

    context 'when file is tab delimited' do
      it 'creates sample & extraction when they do not exist' do
        create(:researcher, username: 'user1')
        csv = './spec/fixtures/import_csv/processing_extraction_tabs.csv'
        file = fixture_file_upload(csv, 'text/csv')

        expect { subject(file, research_project.id, extraction_type.id) }
          .to change { Sample.count }
          .by(1)
          .and change { Extraction.count }
          .by(1)
      end
    end
  end
end
