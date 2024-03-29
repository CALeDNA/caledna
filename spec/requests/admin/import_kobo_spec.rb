# frozen_string_literal: true

require 'rails_helper'

describe 'ImportKobo' do
  def stub_connect_projects
    allow(KoboApi::Connect)
      .to receive_message_chain(:projects, :parsed_response)
      .and_return([{ 'id' => 123, 'title' => 'title' }])
  end

  # rubocop:disable Metrics/MethodLength
  def stub_connect_project
    allow(KoboApi::Connect)
      .to receive_message_chain(:project, :parsed_response)
      .and_return(
        [
          {
            'Get_the_GPS_Location_e_this_more_accurate' => '90, 40, 10, 0',
            '_id' => 1,
            '_attachments' => []
          }
        ]
      )
  end
  # rubocop:enable Metrics/MethodLength

  shared_examples 'allows import access' do
    describe '#GET import_kobo' do
      it 'returns 200' do
        get admin_labwork_import_kobo_path

        expect(response.status).to eq(200)
      end
    end

    describe '#POST import_projects' do
      it 'creates a new project' do
        stub_connect_projects

        expect { post admin_labwork_import_kobo_projects_path }
          .to change(FieldProject, :count).by(1)
      end
    end

    describe '#POST import_samples' do
      it 'creates a new ImportKoboSampleJob' do
        stub_connect_project
        ActiveJob::Base.queue_adapter = :test
        include ActiveJob::TestHelper

        project = create(:field_project, kobo_id: 1)

        expect { post admin_labwork_import_kobo_samples_path(id: project.id) }
          .to have_enqueued_job(ImportKoboSampleJob)
      end
    end
  end

  shared_examples 'denies import access' do
    describe '#GET import_kobo' do
      it 'redirects to admin root page' do
        get admin_labwork_import_kobo_path

        expect(response).to redirect_to admin_samples_path
      end
    end

    describe '#POST import_projects' do
      it 'does not create a new project' do
        stub_connect_projects

        expect { post admin_labwork_import_kobo_projects_path }
          .to change(FieldProject, :count).by(0)
      end
    end

    describe '#POST import_samples' do
      it 'does not create a new sample' do
        stub_connect_project

        project = create(:field_project, kobo_id: 1)

        expect { post admin_labwork_import_samples_path(id: project.id) }
          .to change(Sample, :count).by(0)
      end
    end
  end

  describe 'when researcher is a director' do
    before { login_director }
    include_examples 'allows import access'
  end

  describe 'when researcher is a esie_postdoc' do
    before { login_esie_postdoc }
    include_examples 'allows import access'
  end

  describe 'when researcher is a researcher' do
    before { login_researcher }
    include_examples 'allows import access'
  end
end
