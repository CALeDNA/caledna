# frozen_string_literal: true

require 'rails_helper'

describe CommonNames do
  let(:dummy_class) { Class.new { extend CommonNames } }

  describe '#format_common_names' do
    def subject(names, parenthesis: true, truncate: true, first_only: false)
      dummy_class.format_common_names(
        names, parenthesis: parenthesis, truncate: truncate,
               first_only: first_only
      )
    end

    context 'default behavior' do
      it 'returns common names in parenthesis for 1 to 3 names' do
        results = [
          { names: 'name1', expected: '(name1)' },
          { names: 'name1|name2', expected: '(name1, name2)' },
          { names: 'name1|name2|name3', expected: '(name1, name2, name3)' }
        ]

        results.each do |result|
          expected = result[:expected]

          expect(subject(result[:names])).to eq(expected)
        end
      end

      it 'returns truncated common names in parenthesis when over 3 names' do
        names = 'name1|name2|name3|name4'
        expected = '(name1, name2, name3...)'

        expect(subject(names)).to eq(expected)
      end
    end

    context 'when parenthesis is false' do
      it 'returns common names for 1 to 3 names' do
        results = [
          { names: 'name1', expected: 'name1' },
          { names: 'name1|name2', expected: 'name1, name2' },
          { names: 'name1|name2|name3', expected: 'name1, name2, name3' }
        ]

        results.each do |result|
          expected = result[:expected]

          expect(subject(result[:names], parenthesis: false)).to eq(expected)
        end
      end

      it 'returns truncated common names when over 3 names' do
        names = 'name1|name2|name3|name4'
        expected = 'name1, name2, name3...'

        expect(subject(names, parenthesis: false)).to eq(expected)
      end
    end

    context 'when truncate is false' do
      it 'returns common names in parenthesis' do
        results = [
          { names: 'name1', expected: '(name1)' },
          { names: 'name1|name2', expected: '(name1, name2)' },
          { names: 'name1|name2|name3', expected: '(name1, name2, name3)' },
          { names: 'name1|name2|name3|name4',
            expected: '(name1, name2, name3, name4)' }
        ]

        results.each do |result|
          expected = result[:expected]

          expect(subject(result[:names], truncate: false)).to eq(expected)
        end
      end
    end

    context 'when truncate and parenthesis are false' do
      it 'returns all common names withing parenthesis' do
        results = [
          { names: 'name1', expected: 'name1' },
          { names: 'name1|name2', expected: 'name1, name2' },
          { names: 'name1|name2|name3', expected: 'name1, name2, name3' },
          { names: 'name1|name2|name3|name4',
            expected: 'name1, name2, name3, name4' }
        ]

        results.each do |result|
          expected = result[:expected]

          options = { truncate: false, parenthesis: false }
          expect(subject(result[:names], options)).to eq(expected)
        end
      end
    end

    context 'when first_only is true' do
      let(:results) do
        [
          { names: 'name1', expected: '(name1)' },
          { names: 'name1|name2', expected: '(name1)' },
          { names: 'name1|name2|name3', expected: '(name1)' },
          { names: 'name1|name2|name3|name4', expected: '(name1)' }
        ]
      end

      it 'returns first common name with parenthesis' do
        results.each do |result|
          expected = result[:expected]

          options = { first_only: true }
          expect(subject(result[:names], options)).to eq(expected)
        end
      end

      it 'ignores truncate' do
        results.each do |result|
          expected = result[:expected]

          options = { first_only: true, truncate: false }
          expect(subject(result[:names], options)).to eq(expected)
        end
      end
    end

    context 'when first_only is true and parenthesis is false' do
      it 'returns first common name without parenthesis' do
        results = [
          { names: 'name1', expected: 'name1' },
          { names: 'name1|name2', expected: 'name1' },
          { names: 'name1|name2|name3', expected: 'name1' },
          { names: 'name1|name2|name3|name4', expected: 'name1' }
        ]

        results.each do |result|
          expected = result[:expected]

          options = { first_only: true, parenthesis: false }
          expect(subject(result[:names], options)).to eq(expected)
        end
      end
    end
  end
end
