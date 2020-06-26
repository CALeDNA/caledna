# frozen_string_literal: true

require 'rails_helper'

describe 'Field Projects' do
  describe 'when researcher is a director' do
    before { login_director }

    describe '#GET projects index page' do
      xit 'display project data and actions for projects' do
        create(:field_project, name: 'name1')
        visit admin_field_projects_path

        expect(page).to have_content('name1')
        expect(page).to have_content('Edit')
        expect(page).to have_content('Destroy')
        expect(page).to have_content('New field project')
      end
    end

    describe '#GET projects show page' do
      xit 'display project data and actions for projects' do
        project = create(:field_project, name: 'name1')
        visit admin_field_project_path(id: project.id)

        expect(page).to have_content('name1')
        expect(page).to have_content('Edit name1')
      end
    end

    describe '#GET projects edit page' do
      xit 'display project data and actions for projects' do
        project = create(:field_project, name: 'name1')
        visit edit_admin_field_project_path(id: project.id)

        expect(page).to have_content('name1')
        expect(page).to have_button('Update Field project')
      end
    end
  end

  describe 'when researcher is a esie_postdoc' do
    before { login_esie_postdoc }

    describe '#GET projects index page' do
      xit 'display project data and actions for projects' do
        create(:field_project, name: 'name1')
        visit admin_field_projects_path

        expect(page).to have_content('name1')
        expect(page).to have_content('Edit')
        expect(page).to_not have_content('Destroy')
        expect(page).to_not have_content('New project')
      end
    end

    describe '#GET projects show page' do
      xit 'display project data and actions for projects' do
        project = create(:field_project, name: 'name1')
        visit admin_field_project_path(id: project.id)

        expect(page).to have_content('name1')
        expect(page).to have_content('Edit name1')
      end
    end
  end

  describe 'when researcher is a researcher' do
    before { login_researcher }

    describe '#GET projects index page' do
      xit 'display project data and actions for projects' do
        create(:field_project, name: 'name1')
        visit admin_field_projects_path

        expect(page).to have_content('name1')
        expect(page).to have_content('Edit')
        expect(page).to_not have_content('Destroy')
        expect(page).to_not have_content('New project')
      end
    end

    describe '#GET projects show page' do
      xit 'display project data and actions for projects' do
        project = create(:field_project, name: 'name1')
        visit admin_field_project_path(id: project.id)

        expect(page).to have_content('name1')
        expect(page).to have_content('Edit name1')
      end
    end
  end
end
