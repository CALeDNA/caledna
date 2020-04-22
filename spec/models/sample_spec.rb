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

  describe '#primers' do
    it 'returns an array of unique primers for this sample' do
      sample = create(:sample)
      project1 = create(:research_project)
      project2 = create(:research_project)
      primer1 = create(:primer)
      primer2 = create(:primer)
      create(:sample_primer, sample: sample, primer: primer1,
                             research_project: project1)
      create(:sample_primer, sample: sample, primer: primer2,
                             research_project: project1)
      create(:sample_primer, sample: sample, primer: primer2,
                             research_project: project2)

      expect(sample.primers).to match_array([primer2, primer1])
    end

    it 'ignores primers for other samples' do
      sample = create(:sample)
      sample2 = create(:sample)
      project1 = create(:research_project)
      primer1 = create(:primer)
      create(:sample_primer, sample: sample2, primer: primer1,
                             research_project: project1)

      expect(sample.primers).to match_array([])
    end
  end
end
