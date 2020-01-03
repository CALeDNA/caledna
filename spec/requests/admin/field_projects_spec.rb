# frozen_string_literal: true

require 'rails_helper'

describe 'FieldProjects' do
  shared_examples 'allows create and update access' do
    describe '#POST' do
      it 'does creates a new project' do
        attributes = FactoryBot.attributes_for(:field_project)
        params = { field_project: attributes }

        expect { post admin_field_projects_path, params: params }
          .to change(FieldProject, :count).by(1)
      end
    end

    describe '#PUT' do
      it 'updates a project' do
        project = FactoryBot.create(:field_project, name: 'name1')
        params = { id: project.id, field_project: { name: 'name2' } }
        put admin_field_project_path(id: project.id), params: params
        project.reload

        expect(project.name).to eq('name2')
      end
    end

    describe '#GET projects new page' do
      it 'returns 200' do
        get new_admin_field_project_path

        expect(response.status).to eq(200)
      end
    end

    describe '#GET projects edit page' do
      it 'returns 200' do
        project = create(:field_project, name: 'name1')
        get edit_admin_field_project_path(id: project.id)

        expect(response.status).to eq(200)
      end
    end
  end

  shared_examples 'allows delete access' do
    describe '#DELETE' do
      it 'deletes a project' do
        project = FactoryBot.create(:field_project)

        expect { delete admin_field_project_path(id: project.id) }
          .to change(FieldProject, :count).by(-1)
      end
    end
  end

  shared_examples 'denies delete access' do
    describe '#DELETE' do
      it 'does not delete a project' do
        project = FactoryBot.create(:field_project)

        expect { delete admin_field_project_path(id: project.id) }
          .to change(FieldProject, :count).by(0)
      end
    end
  end

  shared_examples 'allows read access' do
    describe '#GET projects index page' do
      it 'returns 200' do
        create(:field_project)
        get admin_field_projects_path

        expect(response.status).to eq(200)
      end
    end

    describe '#GET projects show page' do
      it 'returns 200' do
        project = create(:field_project)
        get admin_field_project_path(id: project.id)

        expect(response.status).to eq(200)
      end
    end
  end

  describe 'when researcher is a director' do
    before { login_director }
    include_examples 'allows read access'
    include_examples 'allows create and update access'
    include_examples 'allows delete access'
  end

  describe 'when researcher is a esie_postdoc' do
    before { login_esie_postdoc }
    include_examples 'allows read access'
    include_examples 'allows create and update access'
    include_examples 'denies delete access'
  end

  describe 'when researcher is a researcher' do
    before { login_researcher }
    include_examples 'allows read access'
    include_examples 'allows create and update access'
    include_examples 'denies delete access'
  end
end
