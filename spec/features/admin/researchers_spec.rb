# frozen_string_literal: true

require 'rails_helper'

describe 'Researchers' do
  describe 'when researcher is a director' do
    before { login_director }

    describe '#GET researchers index page' do
      it 'display researcher data and actions for researchers' do
        create(:researcher, username: 'my name')
        visit admin_researchers_path

        expect(page).to have_content('my name')
        expect(page).to have_content('Edit')
        expect(page).to have_content('Destroy')
        expect(page).to have_content('New researcher')
      end
    end

    describe '#GET researchers show page' do
      it 'display researcher data and actions for researchers' do
        researcher = create(:researcher, username: 'my name')
        visit admin_researcher_path(id: researcher.id)

        expect(page).to have_content('my name')
        expect(page).to have_content('Edit my name')
      end
    end

    describe '#GET researchers new page' do
      it 'display researcher data and actions for researchers' do
        visit new_admin_researcher_path

        expect(page).to have_button('Send an invitation')
      end
    end

    describe '#GET researchers edit page' do
      it 'display researcher data and actions for researchers' do
        researcher = create(:researcher, username: 'my name')
        visit edit_admin_researcher_path(id: researcher.id)

        expect(page).to have_content('my name')
        expect(page).to have_button('Update Researcher')
      end
    end
  end

  describe 'when researcher is a lab_manager' do
    before { login_lab_manager }

    describe '#GET researchers index page' do
      it 'display researcher data and actions for researchers' do
        create(:researcher, username: 'my name')
        visit admin_researchers_path

        expect(page).to have_content('my name')
        expect(page).to_not have_content('Edit')
        expect(page).to_not have_content('Destroy')
        expect(page).to_not have_content('New researcher')
      end
    end

    describe '#GET researchers show page' do
      it 'display researcher data and actions for researchers' do
        researcher = create(:researcher, username: 'my name')
        visit admin_researcher_path(id: researcher.id)

        expect(page).to have_content('my name')
        expect(page).to_not have_content('Edit my name')
      end
    end
  end

  describe 'when researcher is a researcher_processor' do
    before { login_sample_processor }

    describe '#GET researchers index page' do
      it 'display researcher data and actions for researchers' do
        create(:researcher, username: 'my name')
        visit admin_researchers_path

        expect(page).to have_content('my name')
        expect(page).to_not have_content('Edit')
        expect(page).to_not have_content('Destroy')
        expect(page).to_not have_content('New researcher')
      end
    end

    describe '#GET researchers show page' do
      it 'display researcher data and actions for researchers' do
        researcher = create(:researcher, username: 'my name')
        visit admin_researcher_path(id: researcher.id)

        expect(page).to have_content('You cannot perform this action')
      end
    end
  end
end
