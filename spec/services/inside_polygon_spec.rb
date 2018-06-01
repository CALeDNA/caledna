# frozen_string_literal: true

require 'rails_helper'

describe 'InsidePolygon' do
  let(:dummy_class) { Class.new { extend InsidePolygon } }

  describe '#inside_polygon' do
    def subject(point, polygon)
      dummy_class.inside_polygon(point, polygon)
    end

    it 'returns true if given coordinates are inside the polygon' do
      polygon = [[1, 1], [1, 2], [2, 2], [2, 1]]
      point = [1.5, 1.5]

      expect(subject(point, polygon)).to eq(true)
    end

    it 'returns false if given coordinates are outside the polygon' do
      polygon = [[1, 1], [1, 2], [2, 2], [2, 1]]
      point = [3, 3]

      expect(subject(point, polygon)).to eq(false)
    end

    it 'returns true if given coordinates are inside California' do
      california = InsidePolygon::CALIFORNIA
      los_angeles = [34.052235, -118.243683]

      expect(subject(los_angeles, california)).to eq(true)
    end

    it 'returns false if given coordinates are outside California' do
      california = InsidePolygon::CALIFORNIA
      las_vegas = [36.114647, -115.172813]

      expect(subject(las_vegas, california)).to eq(false)
    end

    it 'returns false if given coordinates are nil' do
      polygon = [[1, 1], [1, 2], [2, 2], [2, 1]]
      point = [nil, nil]

      expect(subject(point, polygon)).to eq(false)
    end

    it 'returns false if first coordinate is nil' do
      polygon = [[1, 1], [1, 2], [2, 2], [2, 1]]
      point = [nil, 1.5]

      expect(subject(point, polygon)).to eq(false)
    end

    it 'returns false if second coordinate nil' do
      polygon = [[1, 1], [1, 2], [2, 2], [2, 1]]
      point = [1.5, nil]

      expect(subject(point, polygon)).to eq(false)
    end
  end
end
