# frozen_string_literal: true

require 'rails_helper'

describe Admin::KoboController do
  before(:each) do
    login_researcher
  end

  def stub_kobo_connect
    allow(KoboApi::Connect)
      .to receive_message_chain(:projects, :parsed_response)
  end

  def stub_kobo_process
    allow(KoboApi::Process)
      .to receive(:import_projects)
  end

  describe '#GET import_projects' do
    it 'returns success' do
      stub_kobo_connect
      stub_kobo_process

      get :list_projects

      expect(response).to have_http_status(200)
    end

    it 'assigns projects' do
      stub_kobo_connect
      stub_kobo_process

      project = create(:project)
      get :list_projects

      expect(assigns[:projects]).to eq([project])
    end

    it 'calls KoboApi::Process.import_projects' do
      kobo_data = [
        { 'id' => 123, 'title' => 'title', 'description' => 'description' }
      ]
      allow(KoboApi::Connect)
        .to receive_message_chain(:projects, :parsed_response)
        .and_return(kobo_data)

      expect(KoboApi::Process).to receive(:import_projects).with(kobo_data)
      get :list_projects
    end

    it 'displays flash message if there is socket connection error' do
      allow(KoboApi::Connect)
        .to receive_message_chain(:projects, :parsed_response) {
          raise SocketError
        }

      get :list_projects

      expect(flash[:error]).to be_present
    end

    it 'displays flash message if imported records are not saved' do
      stub_kobo_connect
      allow(KoboApi::Process)
        .to receive(:import_projects).and_return(false)

      get :list_projects

      expect(flash[:error]).to be_present
    end
  end
end
