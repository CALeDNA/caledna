# frozen_string_literal: true

require 'rails_helper'

describe 'BatchActionController' do
  shared_examples 'can batch edit' do
    describe '#POST approve_samples' do
      it 'changes multiple sample status to approved' do
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
      it 'changes multiple sample longitude' do
        sample1 = create(:sample, barcode: 'KOOO1', id: 1, longitude: 1)
        sample2 = create(:sample, barcode: 'KOOO2', id: 2, longitude: 1)
        params = { batch_action: { ids: [1, 2] } }

        expect { post admin_labwork_batch_change_longitude_sign_path, params: params }
          .to change { sample1.reload.longitude }
          .to(-1)
          .and change { sample2.reload.longitude }.to(-1)
      end
    end
  end

  shared_examples 'can not batch edit' do
    describe '#POST approve_samples' do
      it 'does not change sample status' do
        sample1 = create(:sample, barcode: 'KOOO1', id: 1, status: :submitted)
        params = { batch_action: { ids: [1] } }

        expect { post admin_labwork_batch_approve_samples_path, params: params }
          .to_not(change { sample1.reload.status })
      end
    end

    describe '#POST change_longitude_sign' do
      it 'does not change sample longitude' do
        sample1 = create(:sample, barcode: 'KOOO1', id: 1, longitude: 1)
        params = { batch_action: { ids: [1, 2] } }

        expect { post admin_labwork_batch_change_longitude_sign_path, params: params }
          .to_not(change { sample1.reload.longitude })
      end
    end
  end

  describe 'when researcher is a director' do
    before { login_director }
    include_examples 'can batch edit'
  end

  describe 'when researcher is a lab_manager' do
    before { login_lab_manager }
    include_examples 'can batch edit'
  end

  describe 'when researcher is a sample_processor' do
    before { login_sample_processor }
    include_examples 'can not batch edit'
  end
end
