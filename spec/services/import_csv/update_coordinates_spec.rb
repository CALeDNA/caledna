# frozen_string_literal: true

require 'rails_helper'

describe ImportCsv::UpdateCoordinates do
  let(:dummy_class) { Class.new { extend ImportCsv::UpdateCoordinates } }

  describe '#update_coordinates' do
    def subject(row)
      dummy_class.update_coordinates(row)
    end

    let(:barcode) { 'K0001-LA-S1' }
    let(:row) do
      { 'MatchName' => barcode, 'Latitude' => '40', 'Longitude' => '-120' }
    end

    context 'when multiple samples have same barcode' do
      it 'does not update coordinates' do
        sample1 = create(:sample, barcode: barcode, latitude: 1, longitude: 1)
        sample2 = create(:sample, barcode: barcode, latitude: 1, longitude: 1)

        subject(row)

        expect(sample1.latitude).to eq(1)
        expect(sample1.longitude).to eq(1)
        expect(sample2.latitude).to eq(1)
        expect(sample2.longitude).to eq(1)
      end
    end

    context 'when sample status is missing_coordinates' do
      it 'updates coordinates' do
        sample1 = create(:sample, barcode: barcode, latitude: nil,
                                  longitude: nil,
                                  missing_coordinates: true)

        expect { subject(row) }
          .to change { sample1.reload.latitude }
          .from(nil).to(40)
          .and change { sample1.reload.longitude }
          .from(nil).to(-120)
          .and change { sample1.reload.missing_coordinates }
          .from(true).to(false)
      end
    end

    context 'when sample has wrong sign for longitude' do
      context 'and coordinates are set to 1' do
        it 'updates coordinates with the csv row data' do
          sample1 = create(:sample, barcode: barcode, latitude: 1,
                                    longitude: 1)

          expect { subject(row) }
            .to change { sample1.reload.latitude }
            .to(40)
            .and change { sample1.reload.longitude }
            .to(-120)
        end
      end

      context 'and coordinates are set to real values' do
        it 'updates longitude with the sample data' do
          sample1 = create(:sample, barcode: barcode, latitude: 40.10,
                                    longitude: 120.10)

          expect { subject(row) }
            .to change { sample1.reload.longitude }
            .to(-120.10)
        end

        it 'does not update latitude' do
          sample1 = create(:sample, barcode: barcode, latitude: 40.10,
                                    longitude: 120.10)

          expect { subject(row) }
            .to_not(change { sample1.reload.latitude })
        end
      end
    end

    context 'when sample and csv row coordinates are different' do
      it 'updates coordinates with greater csv row data' do
        sample = create(:sample, barcode: barcode, latitude: 41,
                                 longitude: -119)

        expect { subject(row) }
          .to change { sample.reload.latitude }
          .to(40)
          .and change { sample.reload.longitude }
          .to(-120)
      end

      it 'updates coordinates with lesser csv row data' do
        sample = create(:sample, barcode: barcode, latitude: 39,
                                 longitude: -121)

        expect { subject(row) }
          .to change { sample.reload.latitude }
          .to(40)
          .and change { sample.reload.longitude }
          .to(-120)
      end
    end

    context 'when sample and csv row coordinates have rounding differences' do
      it 'does not update coordinates' do
        sample = create(:sample, barcode: barcode, latitude: 40.001,
                                 longitude: -119.999)
        subject(row)

        expect(sample.latitude).to eq(40.001)
        expect(sample.longitude).to eq(-119.999)
      end

      it 'does not update coordinates' do
        sample = create(:sample, barcode: barcode, latitude: 39.999,
                                 longitude: -120.001)
        subject(row)

        expect(sample.latitude).to eq(39.999)
        expect(sample.longitude).to eq(-120.001)
      end
    end
  end
end
