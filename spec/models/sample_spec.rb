# frozen_string_literal: true

require 'rails_helper'

describe Sample do
  context 'validate with approved samples' do
    let(:barcode) { 'KOO1-LA-S1' }

    it 'invalid when creating multiple approved samples' do
      create(:sample, status_cd: :approved, barcode: barcode)
      sample = build(:sample, status_cd: :approved, barcode: barcode)
      sample.valid?

      message = "barcode #{barcode} is already taken"
      expect(sample.errors.messages[:unique_approved_barcodes].first)
        .to eq(message)
      expect { sample.reload }.to raise_error(ActiveRecord::RecordNotFound)
    end

    it 'invalid when updating multiple approved samples' do
      create(:sample, status_cd: :approved, barcode: barcode)
      sample = create(:sample, status_cd: :submitted, barcode: barcode)
      sample.update(status: :approved)
      sample.valid?

      message = "barcode #{barcode} is already taken"
      expect(sample.errors.messages[:unique_approved_barcodes].first)
        .to eq(message)
      expect(sample.reload.status).to eq(:submitted)
    end

    it 'valid when 1st sample is other status and 2nd sample is approved' do
      create(:sample, status_cd: :submitted, barcode: barcode)

      sample = create(:sample, status_cd: :submitted, barcode: barcode)
      sample.update(status: :approved)

      expect(sample.valid?).to eq(true)
    end

    it 'valid when 1st sample is approved and 2nd sample is other status' do
      create(:sample, status_cd: :approved, barcode: barcode)

      sample = create(:sample, status_cd: :submitted, barcode: barcode)
      sample.update(status: :rejected)

      expect(sample.valid?).to eq(true)
    end

    it 'valid when  updating approved sample' do
      sample = create(:sample, status_cd: :submitted, barcode: barcode)
      sample.update(status: :approved)

      expect(sample.valid?).to eq(true)
    end

    it 'valid when creating approved sample' do
      sample = create(:sample, status_cd: :approved, barcode: barcode)

      expect(sample.valid?).to eq(true)
    end

    it 'valid when sample status stays approved' do
      sample = create(:sample, status_cd: :approved, barcode: barcode)
      sample.update(status: :approved)

      expect(sample.valid?).to eq(true)
    end
  end

  context 'creating a sample' do
    let(:attr) do
      { barcode: :barcode }
    end

    context 'geom does not exist' do
      it 'populates geom with lat and long if lat and long exist' do
        wkt = 'POINT (-20.0 10.0)'
        sample = create(:sample, attr.merge(latitude: 10, longitude: -20))

        expect(sample.geom).is_a?(RGeo::Geos::CAPIPointImpl)
        expect(sample.geom.to_s).to eq(wkt)
      end

      it 'populates geom_projected based on geom if lat and long exist' do
        wkt = 'POINT (-2226389.8158654715 1118889.9748579583)'
        sample = create(:sample, attr.merge(latitude: 10, longitude: -20))
        sample.reload

        expect(sample.geom_projected).is_a?(RGeo::Geos::CAPIPointImpl)
        expect(sample.geom_projected.to_s).to eq(wkt)
      end

      it 'does not populate geom if lat and long do not exist' do
        sample = create(:sample, attr)

        expect(sample.geom).to eq(nil)
      end

      it 'does not populate geom_projected if lat and long do not exist' do
        sample = create(:sample, attr)

        expect(sample.geom_projected).to eq(nil)
      end
    end
  end

  context 'updating a sample' do
    let(:attr) do
      { barcode: :barcode }
    end

    it 'updates geom and geom_projected when lat changes' do
      wkt = 'POINT (-20.0 50.0)'
      wkt_projected = 'POINT (-2226389.8158654715 6446275.841017158)'
      sample = create(:sample, attr.merge(latitude: 10, longitude: -20))
      sample.update(latitude: 50, longitude: -20)
      sample.reload

      expect(sample.geom.to_s).to eq(wkt)
      expect(sample.geom_projected.to_s).to eq(wkt_projected)
    end

    it 'updates geom and geom_projected when lon changes' do
      wkt = 'POINT (-50.0 10.0)'
      wkt_projected = 'POINT (-5565974.539663678 1118889.9748579583)'
      sample = create(:sample, attr.merge(latitude: 10, longitude: -20))
      sample.update(latitude: 10, longitude: -50)
      sample.reload

      expect(sample.geom.to_s).to eq(wkt)
      expect(sample.geom_projected.to_s).to eq(wkt_projected)
    end

    it 'updates geom and geom_projected when lat and lon changes' do
      wkt = 'POINT (-50.0 50.0)'
      wkt_projected = 'POINT (-5565974.539663678 6446275.841017158)'
      sample = create(:sample, attr.merge(latitude: 10, longitude: -20))
      sample.update(latitude: 50, longitude: -50)
      sample.reload

      expect(sample.geom.to_s).to eq(wkt)
      expect(sample.geom_projected.to_s).to eq(wkt_projected)
    end

    it 'does not update geom when lat and lon remain the same' do
      sample = create(:sample, attr.merge(latitude: 10, longitude: -20))
      sample.reload

      expect { sample.update(barcode: 'foo') }.to_not(change { sample.geom })
    end

    it 'does not update geom_projected when lat and lon remain the same' do
      sample = create(:sample, attr.merge(latitude: 10, longitude: -20))
      sample.reload

      expect { sample.update(barcode: 'foo') }
        .to_not(change { sample.geom_projected })
    end
  end

  describe '#valid_barcode?' do
    it 'returns true if barcode is Kxxxx-Lx-Sx format' do
      barcodes = %w[K0000-LA-S1 K9999-LB-S1 K1234-LC-S2]
      barcodes.each do |barcode|
        sample = build(:sample, barcode: barcode)

        expect(sample.valid_barcode?).to eq(true)
      end
    end

    it 'returns false if barcode is invalid Kxxxx-Lx-Sx format' do
      barcodes = %w[KOOOO-LA-S1 K9999-LD-S1 K1234-LC-S5 K001-LA-S1 random
                    fooK0000-LA-S1]
      barcodes.each do |barcode|
        sample = build(:sample, barcode: barcode)

        expect(sample.valid_barcode?).to eq(false)
      end
    end

    it 'returns true if barcode is valid Kxxxx-xx format' do
      barcodes = %w[K0000-A1 K9999-B2 K1234-C3 K5678-E4 K9012-G5 K4567-K6
                    K8901-L7 K2345-M8 K6789-T9]
      barcodes.each do |barcode|
        sample = build(:sample, barcode: barcode)

        expect(sample.valid_barcode?).to eq(true)
      end
    end

    it 'returns true if barcode is invalid Kxxxx-xx format' do
      barcodes = %w[KOOOO-A1 K000-B2 K0000-A2 K0000-B1 random fooK0000-A1]
      barcodes.each do |barcode|
        sample = build(:sample, barcode: barcode)

        expect(sample.valid_barcode?).to eq(false)
      end
    end
  end

  describe '#kobo_data_display' do
    it 'returns empty hash when kobo_data is {}' do
      sample = create(:sample, kobo_data: '{}')
      expect(sample.kobo_data_display).to eq({})
    end

    it 'returns empty hash when kobo_data is {}' do
      sample = create(:sample, kobo_data: { '_id' => 1, 'latitude' => 90 })
      expect(sample.kobo_data_display).to eq('latitude' => 90)
    end
  end
end
