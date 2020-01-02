# frozen_string_literal: true

require 'rails_helper'

describe 'Samples' do
  describe 'when researcher is a director' do
    before { login_director }

    describe '#GET samples index page' do
      it 'display sample data and actions for samples' do
        create(:sample, barcode: '123')
        visit admin_samples_path

        expect(page).to have_content('123')
        expect(page).to have_content('Edit')
        expect(page).to have_content('Destroy')
        expect(page).not_to have_content('New sample')
      end
    end

    describe '#GET samples show page' do
      it 'display sample data and actions for samples' do
        sample = create(:sample, barcode: '123')
        visit admin_sample_path(id: sample.id)

        expect(page).to have_content('123')
        expect(page).to have_content('Edit 123')
      end
    end

    describe '#GET samples edit page' do
      it 'display sample data and actions for samples' do
        sample = create(:sample, barcode: '123')
        visit edit_admin_sample_path(id: sample.id)

        expect(page).to have_content('123')
        expect(page).to have_button('Update Sample')
      end
    end
  end

  describe 'when researcher is a esie_postdoc' do
    before { login_esie_postdoc }

    describe '#GET samples index page' do
      it 'display sample data and actions for samples' do
        create(:sample, barcode: '123')
        visit admin_samples_path

        expect(page).to have_content('123')
        expect(page).to have_content('Edit')
        expect(page).to_not have_content('Destroy')
        expect(page).to_not have_content('New sample')
      end
    end

    describe '#GET samples show page' do
      it 'display sample data and actions for samples' do
        sample = create(:sample, barcode: '123')
        visit admin_sample_path(id: sample.id)

        expect(page).to have_content('123')
        expect(page).to have_content('Edit 123')
      end
    end
  end

  describe 'when researcher is a researcher' do
    before { login_researcher }

    describe '#GET samples index page' do
      it 'display sample data and actions for samples' do
        create(:sample, barcode: '123')
        visit admin_samples_path

        expect(page).to have_content('123')
        expect(page).to have_content('Edit')
        expect(page).to_not have_content('Destroy')
        expect(page).to_not have_content('New sample')
      end
    end

    describe '#GET samples show page' do
      it 'display sample data and actions for samples' do
        sample = create(:sample, barcode: '123')
        visit admin_sample_path(id: sample.id)

        expect(page).to have_content('123')
        expect(page).to have_content('Edit 123')
      end
    end
  end
end
