# frozen_string_literal: true

require 'rails_helper'

describe SqlParser do
  let(:dummy_class) { Class.new { extend SqlParser } }

  describe '#numeric?' do
    def subject(string)
      dummy_class.numeric?(string)
    end

    it 'returns true if string is numeric' do
      values = ['5.5', '23', '-123', '1,234,123']
      values.each do |value|
        expect(subject(value)).to eq(true)
      end
    end

    it 'returns false if string is not numeric' do
      values =  ['hello', '99designs', '(123)456-7890']
      values.each do |value|
        expect(subject(value)).to eq(false)
      end
    end
  end

  describe '#parse_string_arrays' do
    def subject(value)
      dummy_class.parse_string_arrays(value)
    end

    it 'parses empty array' do
      value = '{}'

      expect(subject(value)).to eq([])
    end

    it 'parses array with NULL value' do
      value = '{NULL}'

      expect(subject(value)).to eq([nil])
    end

    it 'parses array with one letter value' do
      value = '{a}'

      expect(subject(value)).to eq(['a'])
    end

    it 'parses array with one number value' do
      value = '{1}'

      expect(subject(value)).to eq([1])
    end

    it 'parses array with multiple values' do
      value = '{1,a,2,NULL}'

      expect(subject(value)).to eq([1, 'a', 2, nil])
    end

    it 'parses strings with spaces' do
      value = '{\"foo bar\",foo,\"baz foo\"}'

      expect(subject(value)).to eq(['foo bar', 'foo', 'baz foo'])
    end

    # rubocop:disable Style/StringLiterals
    it 'parses strings with spaces' do
      value = "{\"foo bar\",foo,\"baz foo\"}"

      expect(subject(value)).to eq(['foo bar', 'foo', 'baz foo'])
    end
    # rubocop:enable Style/StringLiterals
  end
end
