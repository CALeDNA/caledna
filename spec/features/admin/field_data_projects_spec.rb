# frozen_string_literal: true

require 'rails_helper'

describe 'Field Data Projects' do
  describe 'when researcher is a director' do
    before { login_director }

    describe '#GET projects index page' do
      it 'display project data and actions for projects' do
        create(:field_data_project, name: 'name1')
        visit admin_field_data_projects_path

        expect(page).to have_content('name1')
        expect(page).to have_content('Edit')
        expect(page).to have_content('Destroy')
        expect(page).not_to have_content('New field data project')
      end
    end

    describe '#GET projects show page' do
      it 'display project data and actions for projects' do
        project = create(:field_data_project, name: 'name1')
        visit admin_field_data_project_path(id: project.id)

        expect(page).to have_content('name1')
        expect(page).to have_content('Edit name1')
      end
    end

    describe '#GET projects edit page' do
      it 'display project data and actions for projects' do
        project = create(:field_data_project, name: 'name1')
        visit edit_admin_field_data_project_path(id: project.id)

        expect(page).to have_content('name1')
        expect(page).to have_button('Update Field data project')
      end
    end
  end

  describe 'when researcher is a lab_manager' do
    before { login_lab_manager }

    describe '#GET projects index page' do
      it 'display project data and actions for projects' do
        create(:field_data_project, name: 'name1')
        visit admin_field_data_projects_path

        expect(page).to have_content('name1')
        expect(page).to_not have_content('Edit')
        expect(page).to_not have_content('Destroy')
        expect(page).to_not have_content('New project')
      end
    end

    describe '#GET projects show page' do
      it 'display project data and actions for projects' do
        project = create(:field_data_project, name: 'name1')
        visit admin_field_data_project_path(id: project.id)

        expect(page).to have_content('name1')
        expect(page).to_not have_content('Edit name1')
      end
    end
  end

  describe 'when researcher is a sample_processor' do
    before { login_sample_processor }

    describe '#GET projects index page' do
      it 'display project data and actions for projects' do
        create(:field_data_project, name: 'name1')
        visit admin_field_data_projects_path

        expect(page).to have_content('name1')
        expect(page).to_not have_content('Edit')
        expect(page).to_not have_content('Destroy')
        expect(page).to_not have_content('New project')
      end
    end

    describe '#GET projects show page' do
      it 'display project data and actions for projects' do
        project = create(:field_data_project, name: 'name1')
        visit admin_field_data_project_path(id: project.id)

        expect(page).to have_content('name1')
        expect(page).to_not have_content('Edit name1')
      end
    end
  end
end
