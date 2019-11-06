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

  describe '#location_display' do
    it 'converts UCNRS' do
      sample = create(:sample, location: 'a UCNRS b')

      expect(sample.location_display).to eq('a UC Natural Reserve b')
    end

    it 'converts CVMSHCP' do
      sample = create(:sample, location: 'a CVMSHCP b')

      expect(sample.location_display).to eq('a Coachella Valley MSHCP site b')
    end

    it 'converts AUTOMATIC_1' do
      sample = create(:sample, location: 'a AUTOMATIC_1 b')

      expect(sample.location_display).to eq('a b')
    end

    it 'converts AUTOMATIC_2' do
      sample = create(:sample, location: 'a AUTOMATIC_2 b')

      expect(sample.location_display).to eq('a b')
    end

    it 'converts _' do
      sample = create(:sample, location: 'a long_place_name b')

      expect(sample.location_display).to eq('a long place name b')
    end

    it 'converts multiple keywords' do
      sample =
        create(:sample, location: 'a UCNRS b long_place_name c AUTOMATIC_1 d')
      expected = 'a UC Natural Reserve b long place name c d'

      expect(sample.location_display).to eq(expected)
    end

    it 'otherwise returns original string' do
      sample = create(:sample, location: 'a b c d')

      expect(sample.location_display).to eq('a b c d')
    end
  end
end
