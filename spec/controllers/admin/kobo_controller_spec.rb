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

  describe '#GET import_kobo' do
    it 'returns success' do
      get :import_kobo

      expect(response).to have_http_status(200)
    end

    it 'assigns projects' do
      project = create(:project)
      get :import_kobo

      expect(assigns[:projects]).to eq([project])
    end
  end

  describe '#POST import_projects' do
    it 'calls KoboApi::Process and KoboApi::Connect methods' do
      kobo_data = [
        { 'id' => 123, 'title' => 'title', 'description' => 'description' }
      ]
      allow(KoboApi::Connect)
        .to receive_message_chain(:projects, :parsed_response)
        .and_return(kobo_data)

      expect(KoboApi::Process).to receive(:import_projects).with(kobo_data)
      post :import_projects
    end

    it 'displays flash message if there is socket connection error' do
      allow(KoboApi::Connect)
        .to receive_message_chain(:projects, :parsed_response) {
          raise SocketError
        }

      post :import_projects

      expect(flash[:error]).to be_present
    end

    it 'displays flash message if imported records are not saved' do
      stub_kobo_connect
      allow(KoboApi::Process)
        .to receive(:import_projects).and_return(false)

      post :import_projects

      expect(flash[:error]).to be_present
    end
  end

  describe '#POST import_samples' do
    let(:project) { create(:project) }

    it 'calls KoboApi::Process and KoboApi::Connect methods' do
      kobo_data = [
        { 'id' => 123, 'title' => 'title', 'description' => 'description' }
      ]
      allow(KoboApi::Connect)
        .to receive_message_chain(:project, :parsed_response)
        .and_return(kobo_data)

      expect(KoboApi::Process).to receive(:import_samples)
        .with(project.id, kobo_data)
      post :import_samples, params: { id: project.id }
    end

    it 'displays flash message if there is socket connection error' do
      allow(KoboApi::Connect)
        .to receive_message_chain(:project, :parsed_response) {
          raise SocketError
        }

      post :import_samples, params: { id: project.id }

      expect(flash[:error]).to be_present
    end

    it 'displays flash message if imported records are not saved' do
      stub_kobo_connect
      allow(KoboApi::Process)
        .to receive(:import_samples).and_return(false)

      post :import_samples, params: { id: project.id }

      expect(flash[:error]).to be_present
    end
  end
end
