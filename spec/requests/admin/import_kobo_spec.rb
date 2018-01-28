# frozen_string_literal: true

require 'rails_helper'

describe 'ImportKobo' do
  shared_examples 'allows import access' do
    describe '#GET import_kobo' do
      it 'returns 200' do
        get admin_import_kobo_path

        expect(response.status).to eq(200)
      end
    end

    describe '#POST import_projects' do
      it 'creates a new project' do
        attributes = FactoryBot.attributes_for(:project)
        params = { project: attributes }

        expect { post admin_projects_path, params: params }
          .to change(Project, :count).by(1)
      end
    end

    describe '#POST import_samples' do
      it 'creates a new sample' do
        project = create(:project)
        attributes = { bar_code: '123', project_id: project.id }
        params = { id: project.id, sample: attributes }

        expect { post admin_samples_path, params: params }
          .to change(Sample, :count).by(1)
      end
    end
  end

  shared_examples 'denies import access' do
    describe '#GET import_kobo' do
      it 'redirects to admin root page' do
        get admin_import_kobo_path

        expect(response).to redirect_to admin_samples_path
      end
    end

    describe '#POST import_projects' do
      it 'does not create a new project' do
        attributes = FactoryBot.attributes_for(:project)
        params = { project: attributes }

        expect { post admin_projects_path, params: params }
          .to change(Project, :count).by(0)
      end
    end

    describe '#POST import_samples' do
      it 'does not create a new sample' do
        project = create(:project)
        attributes = { bar_code: '123', project_id: project.id }
        params = { id: project.id, sample: attributes }

        expect { post admin_samples_path, params: params }
          .to change(Sample, :count).by(0)
      end
    end
  end

  describe 'when researcher is a director' do
    before { login_director }
    include_examples 'allows import access'
  end

  describe 'when researcher is a lab_manager' do
    before { login_lab_manager }
    include_examples 'denies import access'
  end

  describe 'when researcher is a sample_processor' do
    before { login_sample_processor }
    include_examples 'denies import access'
  end
end
