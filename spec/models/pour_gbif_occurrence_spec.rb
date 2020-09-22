# frozen_string_literal: true

require 'rails_helper'

describe PourGbifOccurrence do
  context 'creating a pour_gbif_occurrence' do
    let(:attr) do
      {}
    end

    context 'geom does not exist' do
      it 'populates geom with lat and long if lat and long exist' do
        wkt = 'POINT (-20.0 10.0)'
        pour_gbif_occurrence =
          create(:pour_gbif_occurrence,
                 attr.merge(latitude: 10, longitude: -20))

        expect(pour_gbif_occurrence.geom).is_a?(RGeo::Geos::CAPIPointImpl)
        expect(pour_gbif_occurrence.geom.to_s).to eq(wkt)
      end

      it 'populates geom_projected based on geom if lat and long exist' do
        wkt = 'POINT (-2226389.8158654715 1118889.9748579583)'
        pour_gbif_occurrence =
          create(:pour_gbif_occurrence,
                 attr.merge(latitude: 10, longitude: -20))
        pour_gbif_occurrence.reload

        expect(pour_gbif_occurrence.geom_projected)
          .is_a?(RGeo::Geos::CAPIPointImpl)
        expect(pour_gbif_occurrence.geom_projected.to_s).to eq(wkt)
      end

      it 'does not populate geom if lat and long do not exist' do
        pour_gbif_occurrence = create(:pour_gbif_occurrence, attr)

        expect(pour_gbif_occurrence.geom).to eq(nil)
      end

      it 'does not populate geom_projected if lat and long do not exist' do
        pour_gbif_occurrence = create(:pour_gbif_occurrence, attr)

        expect(pour_gbif_occurrence.geom_projected).to eq(nil)
      end
    end
  end

  context 'updating a pour_gbif_occurrence' do
    let(:attr) do
      {}
    end

    it 'updates geom and geom_projected when lat changes' do
      wkt = 'POINT (-20.0 50.0)'
      wkt_projected = 'POINT (-2226389.8158654715 6446275.841017158)'
      pour_gbif_occurrence =
        create(:pour_gbif_occurrence, attr.merge(latitude: 10, longitude: -20))
      pour_gbif_occurrence.update(latitude: 50, longitude: -20)
      pour_gbif_occurrence.reload

      expect(pour_gbif_occurrence.geom.to_s).to eq(wkt)
      expect(pour_gbif_occurrence.geom_projected.to_s).to eq(wkt_projected)
    end

    it 'updates geom and geom_projected when lon changes' do
      wkt = 'POINT (-50.0 10.0)'
      wkt_projected = 'POINT (-5565974.539663678 1118889.9748579583)'
      pour_gbif_occurrence =
        create(:pour_gbif_occurrence, attr.merge(latitude: 10, longitude: -20))
      pour_gbif_occurrence.update(latitude: 10, longitude: -50)
      pour_gbif_occurrence.reload

      expect(pour_gbif_occurrence.geom.to_s).to eq(wkt)
      expect(pour_gbif_occurrence.geom_projected.to_s).to eq(wkt_projected)
    end

    it 'updates geom and geom_projected when lat and lon changes' do
      wkt = 'POINT (-50.0 50.0)'
      wkt_projected = 'POINT (-5565974.539663678 6446275.841017158)'
      pour_gbif_occurrence =
        create(:pour_gbif_occurrence, attr.merge(latitude: 10, longitude: -20))
      pour_gbif_occurrence.update(latitude: 50, longitude: -50)
      pour_gbif_occurrence.reload

      expect(pour_gbif_occurrence.geom.to_s).to eq(wkt)
      expect(pour_gbif_occurrence.geom_projected.to_s).to eq(wkt_projected)
    end

    it 'does not update geom when lat and lon remain the same' do
      pour_gbif_occurrence =
        create(:pour_gbif_occurrence, attr.merge(latitude: 10, longitude: -20))
      pour_gbif_occurrence.reload

      expect { pour_gbif_occurrence.update(taxon_rank: 'foo') }
        .to_not(change { pour_gbif_occurrence.geom })
    end

    it 'does not update geom_projected when lat and lon remain the same' do
      pour_gbif_occurrence =
        create(:pour_gbif_occurrence, attr.merge(latitude: 10, longitude: -20))
      pour_gbif_occurrence.reload

      expect { pour_gbif_occurrence.update(taxon_rank: 'foo') }
        .to_not(change { pour_gbif_occurrence.geom_projected })
    end
  end
end
