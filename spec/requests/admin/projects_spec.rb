# frozen_string_literal: true

require 'rails_helper'

describe 'Projects' do
  shared_examples 'allows write access' do
    describe '#POST' do
      it 'creates a new project' do
        attributes = FactoryBot.attributes_for(:project)
        params = { project: attributes }

        expect { post admin_projects_path, params: params }
          .to change(Project, :count).by(1)
      end
    end

    describe '#PUT' do
      it 'updates a project' do
        project = FactoryBot.create(:project, name: 'name1')
        params = { id: project.id, project: { name: 'name2' } }
        put admin_project_path(id: project.id), params: params
        project.reload

        expect(project.name).to eq('name2')
      end
    end

    describe '#DELETE' do
      it 'deletes a project' do
        project = FactoryBot.create(:project)

        expect { delete admin_project_path(id: project.id) }
          .to change(Project, :count).by(-1)
      end
    end

    describe '#GET projects new page' do
      it 'redirects to admin root' do
        get new_admin_sample_path

        expect(response.status).to eq(200)
      end
    end

    describe '#GET projects edit page' do
      it 'redirects to admin root' do
        project = create(:project, name: 'name1')
        get edit_admin_project_path(id: project.id)

        expect(response.status).to eq(200)
      end
    end
  end

  shared_examples 'denies write access' do
    describe '#POST' do
      it 'does not create a new project' do
        attributes = FactoryBot.attributes_for(:project)
        params = { project: attributes }

        expect { post admin_projects_path, params: params }
          .to change(Project, :count).by(0)
      end
    end

    describe '#PUT' do
      it 'does not update a project' do
        project = FactoryBot.create(:project, name: 'name1')
        params = { id: project.id, project: { name: 'name2' } }
        put admin_project_path(id: project.id), params: params
        project.reload

        expect(project.name).to eq('name1')
      end
    end

    describe '#DELETE' do
      it 'does not delete a project' do
        project = FactoryBot.create(:project)

        expect { delete admin_project_path(id: project.id) }
          .to change(Project, :count).by(0)
      end
    end

    describe '#GET projects new page' do
      it 'redirects to admin root' do
        get new_admin_sample_path

        expect(response).to redirect_to admin_samples_path
      end
    end

    describe '#GET projects edit page' do
      it 'redirects to admin root' do
        project = create(:project, name: 'name1')
        get edit_admin_project_path(id: project.id)

        expect(response).to redirect_to admin_samples_path
      end
    end
  end

  shared_examples 'allows read access' do
    describe '#GET projects index page' do
      it 'returns 200' do
        create(:project)
        get admin_projects_path

        expect(response.status).to eq(200)
      end
    end

    describe '#GET projects show page' do
      it 'returns 200' do
        project = create(:project)
        get admin_project_path(id: project.id)

        expect(response.status).to eq(200)
      end
    end
  end

  describe 'when researcher is a director' do
    before { login_director }
    include_examples 'allows read access'
    include_examples 'allows write access'
  end

  describe 'when researcher is a lab_manager' do
    before { login_lab_manager }
    include_examples 'allows read access'
    include_examples 'denies write access'
  end

  describe 'when researcher is a sample_processor' do
    before { login_sample_processor }
    include_examples 'allows read access'
    include_examples 'denies write access'
  end
end
