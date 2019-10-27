# frozen_string_literal: true

require 'rails_helper'

describe Admin::Labwork::KoboController do
  before(:each) do
    login_director
  end

  def stub_kobo_connect
    allow(KoboApi::Connect)
      .to receive_message_chain(:projects, :parsed_response)
  end

  def stub_kobo_process
    allow(KoboApi::Process)
      .to receive_message_chain(:new, :import_projects)
  end

  describe '#GET import_kobo' do
    it 'returns success' do
      get :import_kobo

      expect(response).to have_http_status(200)
    end

    it 'assigns projects' do
      project = create(:field_project)
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

      # TODO: add test for if module method is called
      # expect(KoboApi::Process).to receive(:import_kobo_projects)
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
  end

  describe '#POST import_samples' do
    let(:kobo_id) { 10 }
    let(:project) { create(:field_project, kobo_id: kobo_id) }

    it 'calls KoboApi::Process and KoboApi::Connect methods' do
      kobo_data = [
        { 'id' => 123, 'title' => 'title', 'description' => 'description' }
      ]
      allow(KoboApi::Connect)
        .to receive_message_chain(:project, :parsed_response)
        .and_return(kobo_data)

      # TODO: add test for if module method is called
      # expect(KoboApi::Process).to receive_message_chain(:new, :import_samples)
      #   .with(project.id, kobo_id, kobo_data)

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
  end
end
