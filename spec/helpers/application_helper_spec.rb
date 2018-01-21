# frozen_string_literal: true

require 'rails_helper'

describe ApplicationHelper do
  describe '#short_date' do
    it 'returns a formatted date for a given date' do
      date = Time.new('2000-01-02')
      subject = short_date(date)
      expected = l(date, format: :short)

      expect(subject).to eq(expected)
    end

    it 'returns nil if no date is given' do
      subject = short_date(nil)

      expect(subject).to eq(nil)
    end
  end

  describe '#long_date' do
    it 'returns a formatted date for a given date' do
      date = Time.new('2000-01-02')
      subject = long_date(date)
      expected = l(date, format: :long)

      expect(subject).to eq(expected)
    end

    it 'returns nil if no date is given' do
      subject = long_date(nil)
      expect(subject).to eq(nil)
    end
  end
end
