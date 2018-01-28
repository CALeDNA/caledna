# frozen_string_literal: true

require 'rails_helper'

describe 'Samples' do
  describe 'when researcher is a director' do
    before { login_director }

    describe '#GET samples index page' do
      it 'display sample data and actions for samples' do
        create(:sample, bar_code: '123')
        visit admin_samples_path

        expect(page).to have_content('123')
        expect(page).to have_content('Edit')
        expect(page).to have_content('Destroy')
        expect(page).to have_content('New sample')
      end
    end

    describe '#GET samples show page' do
      it 'display sample data and actions for samples' do
        sample = create(:sample, bar_code: '123')
        visit admin_sample_path(id: sample.id)

        expect(page).to have_content('123')
        expect(page).to have_content('Edit 123')
      end
    end

    describe '#GET samples new page' do
      it 'display sample data and actions for samples' do
        visit new_admin_sample_path

        expect(page).to have_button('Create Sample')
      end
    end

    describe '#GET samples edit page' do
      it 'display sample data and actions for samples' do
        sample = create(:sample, bar_code: '123')
        visit edit_admin_sample_path(id: sample.id)

        expect(page).to have_content('123')
        expect(page).to have_button('Update Sample')
      end
    end
  end

  describe 'when researcher is a lab_manager' do
    before { login_lab_manager }

    describe '#GET samples index page' do
      it 'display sample data and actions for samples' do
        create(:sample, bar_code: '123')
        visit admin_samples_path

        expect(page).to have_content('123')
        expect(page).to have_content('Edit')
        expect(page).to_not have_content('Destroy')
        expect(page).to_not have_content('New sample')
      end
    end

    describe '#GET samples show page' do
      it 'display sample data and actions for samples' do
        sample = create(:sample, bar_code: '123')
        visit admin_sample_path(id: sample.id)

        expect(page).to have_content('123')
        expect(page).to have_content('Edit 123')
      end
    end
  end

  describe 'when researcher is a sample_processor' do
    before { login_sample_processor }

    describe '#GET samples index page' do
      it 'display sample data and actions for samples' do
        processor = Researcher.with_role(:sample_processor).first
        create(:sample, bar_code: '123', processor: processor)
        visit admin_samples_path

        expect(page).to have_content('123')
        expect(page).to have_content('Edit')
        expect(page).to_not have_content('Destroy')
        expect(page).to_not have_content('New sample')
      end
    end

    describe '#GET samples show page' do
      it 'display sample data and actions for samples' do
        processor = Researcher.with_role(:sample_processor).first
        sample = create(:sample, bar_code: '123', processor: processor)
        visit admin_sample_path(id: sample.id)

        expect(page).to have_content('123')
        expect(page).to have_content('Edit 123')
      end
    end
  end
end
