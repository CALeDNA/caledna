# frozen_string_literal: true

require 'rails_helper'

describe 'Import Kobo' do
  describe 'when researcher is a director' do
    before { login_director }

    describe '#GET import_kobo' do
      it 'display project data and actions for researchers' do
        create(:field_project, name: 'project name')
        visit admin_labwork_import_kobo_path

        expect(page).to have_content('project name')
        expect(page).to have_button('Import Projects')
        expect(page).to have_button('Import Samples')
      end
    end
  end

  describe 'when researcher is a esie_postdoc' do
    before { login_esie_postdoc }

    describe '#GET import_kobo' do
      it 'display project data and actions for researchers' do
        create(:field_project, name: 'project name')
        visit admin_labwork_import_kobo_path

        expect(page).to have_content('project name')
        expect(page).to have_button('Import Projects')
        expect(page).to have_button('Import Samples')
      end
    end
  end

  describe 'when researcher is a researcher' do
    before { login_researcher }

    describe '#GET import_kobo' do
      it 'display project data and actions for researchers' do
        create(:field_project, name: 'project name')
        visit admin_labwork_import_kobo_path

        expect(page).to have_content('project name')
        expect(page).to have_button('Import Projects')
        expect(page).to have_button('Import Samples')
      end
    end
  end
end
