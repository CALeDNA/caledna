# frozen_string_literal: true

require 'rails_helper'

describe Place do
  context 'creating a place' do
    let(:attr) do
      { name: :name, place_type: :state, place_source_type: :census }
    end

    context 'geom does not exist' do
      it 'populates geom with lat and long if lat and long exist' do
        wkt = 'POINT (-20.0 10.0)'
        place = create(:place, attr.merge(latitude: 10, longitude: -20))

        expect(place.geom).is_a?(RGeo::Geos::CAPIPointImpl)
        expect(place.geom.to_s).to eq(wkt)
      end

      it 'populates geom_projected based on geom if lat and long exist' do
        wkt = 'POINT (-2226389.8158654715 1118889.9748579583)'
        place = create(:place, attr.merge(latitude: 10, longitude: -20))
        place.reload

        expect(place.geom_projected).is_a?(RGeo::Geos::CAPIPointImpl)
        expect(place.geom_projected.to_s).to eq(wkt)
      end

      it 'does not populate geom if lat and long do not exist' do
        place = create(:place, attr)

        expect(place.geom).to eq(nil)
      end

      it 'does not populate geom_projected if lat and long do not exist' do
        place = create(:place, attr)

        expect(place.geom_projected).to eq(nil)
      end
    end

    context 'geom exists' do
      it 'uses the existing geom' do
        wkt = 'LINESTRING (1.0 2.0, 3.0 4.0)'
        place = create(:place, attr.merge(latitude: 10, longitude: -20,
                                          geom: wkt))

        expect(place.geom).is_a?(RGeo::Geos::CAPILineStringImpl)
        expect(place.geom.to_s).to eq(wkt)
      end

      it 'adds geom_projected based on geom' do
        wkt = 'LINESTRING (1.0 2.0, 3.0 4.0)'
        wkt_projected = 'LINESTRING (111319.49079327357 222684.20850554318, ' \
          '333958.4723798207 445640.1096560266)'
        place = create(:place, attr.merge(latitude: 10, longitude: -20,
                                          geom: wkt))
        place.reload

        expect(place.geom_projected).is_a?(RGeo::Geos::CAPILineStringImpl)
        expect(place.geom_projected.to_s).to eq(wkt_projected)
      end
    end
  end

  context 'updating a place' do
    let(:attr) do
      { name: :name, place_type: :state, place_source_type: :census }
    end

    context 'place is a point' do
      it 'updates geom and geom_projected when lat changes' do
        wkt = 'POINT (-20.0 50.0)'
        wkt_projected = 'POINT (-2226389.8158654715 6446275.841017158)'
        place = create(:place, attr.merge(latitude: 10, longitude: -20))
        place.update(latitude: 50, longitude: -20)
        place.reload

        expect(place.geom.to_s).to eq(wkt)
        expect(place.geom_projected.to_s).to eq(wkt_projected)
      end

      it 'updates geom and geom_projected when lon changes' do
        wkt = 'POINT (-50.0 10.0)'
        wkt_projected = 'POINT (-5565974.539663678 1118889.9748579583)'
        place = create(:place, attr.merge(latitude: 10, longitude: -20))
        place.update(latitude: 10, longitude: -50)
        place.reload

        expect(place.geom.to_s).to eq(wkt)
        expect(place.geom_projected.to_s).to eq(wkt_projected)
      end

      it 'updates geom and geom_projected when lat and lon changes' do
        wkt = 'POINT (-50.0 50.0)'
        wkt_projected = 'POINT (-5565974.539663678 6446275.841017158)'
        place = create(:place, attr.merge(latitude: 10, longitude: -20))
        place.update(latitude: 50, longitude: -50)
        place.reload

        expect(place.geom.to_s).to eq(wkt)
        expect(place.geom_projected.to_s).to eq(wkt_projected)
      end

      it 'does not update geom when lat and lon remain the same' do
        place = create(:place, attr.merge(latitude: 10, longitude: -20))
        place.reload

        expect { place.update(name: 'name') }.to_not(change { place.geom })
      end

      it 'does not update geom_projected when lat and lon remain the same' do
        place = create(:place, attr.merge(latitude: 10, longitude: -20))
        place.reload

        expect { place.update(name: 'name') }
          .to_not(change { place.geom_projected })
      end
    end

    context 'place is not a point' do
      it 'does not update geom when lat and lon change' do
        wkt = 'LINESTRING (1.0 2.0, 3.0 4.0)'
        place = create(:place, attr.merge(latitude: 10, longitude: -20,
                                          geom: wkt))
        place.reload

        expect { place.update(latitude: 50, longitude: -50) }
          .to_not(change { place.geom })
      end

      it 'does not update geom_projected when lat and lon change' do
        wkt = 'LINESTRING (1.0 2.0, 3.0 4.0)'
        place = create(:place, attr.merge(latitude: 10, longitude: -20,
                                          geom: wkt))
        place.reload

        expect { place.update(latitude: 50, longitude: -50) }
          .to_not(change { place.geom_projected })
      end

      it 'updates geom and geom_projected when geom change' do
        wkt = 'LINESTRING (1.0 2.0, 3.0 4.0)'
        wkt_update = 'LINESTRING (5.0 6.0, 7.0 8.0)'
        wkt_projected = 'LINESTRING (556597.4539663679 669141.0570442441, ' \
          '779236.435552915 893463.7510126441)'
        place = create(:place, attr.merge(latitude: 10, longitude: -20,
                                          geom: wkt))
        place.reload

        expect { place.update(geom: wkt_update) }
          .to change { place.geom.to_s }
          .to(wkt_update)
          .and change { place.reload.geom_projected.to_s }
          .to(wkt_projected)
      end
    end
  end
end
