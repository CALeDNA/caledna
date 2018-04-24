# frozen_string_literal: true

require 'rails_helper'

describe CsvUtils do
  let(:dummy_class) { Class.new { extend CsvUtils } }

  describe '#delimiter_detector' do
    def subject(path)
      dummy_class.delimiter_detector(path)
    end

    it 'returns a tab when delimiter is \t' do
      path = './spec/fixtures/csv/tab.csv'
      expect(subject(path)).to eq("\t")
    end

    it 'returns a tab when delimiter is "\t"' do
      path = './spec/fixtures/csv/tab_with_quotes.csv'
      expect(subject(path)).to eq("\t")
    end

    it 'returns a comma when delimiter is ,' do
      path = './spec/fixtures/csv/comma.csv'
      expect(subject(path)).to eq(',')
    end

    it 'returns a comma when delimiter is ","' do
      path = './spec/fixtures/csv/comma_with_quotes.csv'
      expect(subject(path)).to eq(',')
    end
  end
end
