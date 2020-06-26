# frozen_string_literal: true

require 'rails_helper'

describe 'BatchActionController' do
  shared_examples 'can batch edit' do
    describe '#POST approve_samples' do
      xit 'changes multiple sample status to approved' do
        sample1 = create(:sample, barcode: 'KOOO1', id: 1, status: :submitted)
        sample2 = create(:sample, barcode: 'KOOO2', id: 2, status: :submitted)
        params = { batch_action: { ids: [1, 2] } }

        expect { post admin_labwork_batch_approve_samples_path, params: params }
          .to change { sample1.reload.status }
          .to(:approved)
          .and change { sample2.reload.status }.to(:approved)
      end
    end

    describe '#POST change_longitude_sign' do
      def point_factory(lon, lat)
        RGeo::Cartesian.preferred_factory(srid: 3785).point(lon, lat)
      end

      it 'changes multiple sample longitude' do
        sample1 = create(:sample, barcode: 'KOOO1', id: 1,
                                  longitude: 1, latitude: 2)
        sample2 = create(:sample, barcode: 'KOOO2', id: 2,
                                  longitude: 3, latitude: 4)
        params = { batch_action: { ids: [1, 2] } }
        path = admin_labwork_batch_change_longitude_sign_path

        expect { post path, params: params }
          .to change { sample1.reload.longitude }
          .to(-1)
          .and change { sample1.reload.geom }
          .to(point_factory(-1, 2))
          .and change { sample2.reload.longitude }
          .to(-3)
          .and change { sample2.reload.geom }
          .to(point_factory(-3, 4))
      end
    end
  end

  shared_examples 'can not batch edit' do
    describe '#POST approve_samples' do
      xit 'does not change sample status' do
        sample1 = create(:sample, barcode: 'KOOO1', id: 1, status: :submitted)
        params = { batch_action: { ids: [1] } }

        expect { post admin_labwork_batch_approve_samples_path, params: params }
          .to_not(change { sample1.reload.status })
      end
    end

    describe '#POST change_longitude_sign' do
      xit 'does not change sample longitude' do
        sample1 = create(:sample, barcode: 'KOOO1', id: 1, longitude: 1)
        params = { batch_action: { ids: [1, 2] } }
        path = admin_labwork_batch_change_longitude_sign_path

        expect { post path, params: params }
          .to_not(change { sample1.reload.longitude })
      end
    end
  end

  describe 'when researcher is a director' do
    before { login_director }
    include_examples 'can batch edit'
  end

  describe 'when researcher is a esie_postdoc' do
    before { login_esie_postdoc }
    include_examples 'can batch edit'
  end

  describe 'when researcher is a researcher' do
    before { login_researcher }
    include_examples 'can batch edit'
  end
end
