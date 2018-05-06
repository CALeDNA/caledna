# frozen_string_literal: true

require 'rails_helper'

describe CsvUtils do
  let(:dummy_class) { Class.new { extend CsvUtils } }

  describe '#delimiter_detector' do
    def subject(path)
      dummy_class.delimiter_detector(path)
    end

    it 'returns a tab when delimiter is \t' do
      csv = './spec/fixtures/csv/tab.csv'
      file = fixture_file_upload(csv, 'text/csv')

      expect(subject(file)).to eq("\t")
    end

    it 'returns a tab when delimiter is "\t"' do
      csv = './spec/fixtures/csv/tab_with_quotes.csv'
      file = fixture_file_upload(csv, 'text/csv')

      expect(subject(file)).to eq("\t")
    end

    it 'returns a comma when delimiter is ,' do
      csv = './spec/fixtures/csv/comma.csv'
      file = fixture_file_upload(csv, 'text/csv')

      expect(subject(file)).to eq(',')
    end

    it 'returns a comma when delimiter is ","' do
      csv = './spec/fixtures/csv/comma_with_quotes.csv'
      file = fixture_file_upload(csv, 'text/csv')

      expect(subject(file)).to eq(',')
    end
  end
end
