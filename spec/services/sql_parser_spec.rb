# frozen_string_literal: true

require 'rails_helper'

describe SqlParser do
  let(:dummy_class) { Class.new { extend SqlParser } }

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

      expect(subject(value)).to eq([])
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

      expect(subject(value)).to eq([1, 'a', 2])
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

    it 'parses strings with commas' do
      value = "{\"a,a\",1,b,'c,c'}"

      expect(subject(value)).to eq(['a,a', 1, 'b', 'c,c'])
    end

    it 'parses strings with :' do
      value = '{a:b,c,d:e}'

      expect(subject(value)).to eq(['a:b', 'c', 'd:e'])
    end

    it 'parses strings with ?' do
      value = '{a?b,c,d?e}'

      expect(subject(value)).to eq(['a?b', 'c', 'd?e'])
    end
  end
end
