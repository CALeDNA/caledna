# frozen_string_literal: true

require 'rails_helper'

describe 'Samples' do
  shared_examples 'allows read access' do
    describe '#GET samples index page' do
      it 'returns 200' do
        create(:sample)
        get admin_samples_path

        expect(response.status).to eq(200)
      end
    end

    describe '#GET samples show page' do
      it 'returns 200' do
        sample = create(:sample)
        get admin_sample_path(id: sample.id)

        expect(response.status).to eq(200)
      end
    end
  end

  shared_examples 'allows full write access' do
    describe '#POST' do
      it 'does not creates a new sample' do
        attributes = {
          barcode: '123',
          field_project_id: create(:field_project).id
        }
        params = { sample: attributes }

        expect { post admin_samples_path, params: params }
          .to change(Sample, :count).by(0)
      end
    end

    describe '#PUT' do
      it 'updates a sample' do
        sample = FactoryBot.create(:sample, barcode: '123')
        params = { id: sample.id, sample: { barcode: 'abc' } }
        put admin_sample_path(id: sample.id), params: params
        sample.reload

        expect(sample.barcode).to eq('abc')
      end
    end

    describe '#DELETE' do
      it 'deletes a sample' do
        sample = FactoryBot.create(:sample)

        expect { delete admin_sample_path(id: sample.id) }
          .to change(Sample, :count).by(-1)
      end
    end

    describe '#GET samples edit page' do
      it 'redirects to admin root' do
        sample = create(:sample, barcode: '123')
        get edit_admin_sample_path(id: sample.id)

        expect(response.status).to eq(200)
      end
    end
  end

  shared_examples 'denies create access' do
    describe '#POST' do
      it 'does not create a new sample' do
        attributes = {
          barcode: '123',
          field_project_id: create(:field_project).id
        }
        params = { sample: attributes }

        expect { post admin_samples_path, params: params }
          .to change(Sample, :count).by(0)
      end
    end

    describe '#GET samples new page' do
      it 'redirects to admin root' do
        get new_admin_sample_path

        expect(response).to redirect_to admin_samples_path
      end
    end
  end

  shared_examples 'allows edit access' do
    describe '#PUT' do
      it 'updates a sample' do
        sample = FactoryBot.create(:sample, barcode: '123')
        params = { id: sample.id, sample: { barcode: 'abc' } }
        put admin_sample_path(id: sample.id), params: params
        sample.reload

        expect(sample.barcode).to eq('abc')
      end
    end

    describe '#GET samples edit page' do
      it 'redirects to admin root' do
        sample = create(:sample, barcode: '123')
        get edit_admin_sample_path(id: sample.id)

        expect(response.status).to eq(200)
      end
    end
  end

  shared_examples 'denies delete access' do
    describe '#DELETE' do
      it 'does not delete a sample' do
        sample = FactoryBot.create(:sample)

        expect { delete admin_sample_path(id: sample.id) }
          .to change(Sample, :count).by(0)
      end
    end
  end

  shared_examples 'denies delete access' do
    describe '#DELETE' do
      it 'does not delete a sample' do
        sample = FactoryBot.create(:sample)

        expect { delete admin_sample_path(id: sample.id) }
          .to change(Sample, :count).by(0)
      end
    end
  end

  shared_examples 'denies edit access' do
    describe '#GET samples edit page' do
      it 'returns 302' do
        sample = FactoryBot.create(:sample, barcode: '123')
        get edit_admin_sample_path(id: sample.id)

        expect(response.status).to eq(302)
      end
    end
  end

  describe 'when researcher is a director' do
    before { login_director }
    include_examples 'allows read access'
    include_examples 'allows full write access'
  end

  describe 'when researcher is a lab_manager' do
    before { login_lab_manager }
    include_examples 'allows read access'
    include_examples 'denies create access'
    include_examples 'allows edit access'
    include_examples 'denies delete access'
  end

  describe 'when researcher is a sample_processor' do
    before { login_sample_processor }
    include_examples 'allows read access'
    include_examples 'denies create access'
    include_examples 'denies edit access'
    include_examples 'denies delete access'
  end
end
