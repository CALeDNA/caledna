# frozen_string_literal: true

require 'rails_helper'

describe 'Import Kobo' do
  describe 'when researcher is a director' do
    before { login_director }

    describe '#GET import_kobo' do
      it 'display project data and actions for researchers' do
        create(:field_data_project, name: 'project name')
        visit admin_import_kobo_path

        expect(page).to have_content('project name')
        expect(page).to have_button('Import Projects')
        expect(page).to have_button('Import Samples')
      end
    end
  end

  describe 'when researcher is a lab_manager' do
    before { login_lab_manager }

    describe '#GET import_kobo' do
      it 'denies access' do
        visit admin_import_kobo_path

        expect(page).to have_content('You cannot perform this action')
      end
    end
  end

  describe 'when researcher is a researcher_processor' do
    before { login_sample_processor }

    describe '#GET import_kobo' do
      it 'denies access' do
        visit admin_import_kobo_path

        expect(page).to have_content('You cannot perform this action')
      end
    end
  end
end
