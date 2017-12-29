# frozen_string_literal: true

require 'rails_helper'

describe Admin::ResearchersController do
  describe '#GET index' do
    it 'redirects if user is not logged in' do
      get :index

      expect(response).to have_http_status(302)
    end

    it 'succedes if user is logged in' do
      login_researcher
      get :index

      expect(response).to have_http_status(200)
    end
  end

  describe '#PUT update' do
    before(:each) do
      login_researcher
    end

    let(:researcher) { FactoryBot.create(:researcher, email: old_email) }
    let(:old_email) { 'a@a.com' }
    let(:new_email) { 'b@b.com' }

    it 'updates attributes' do
      params = { id: researcher.id, researcher: { email: new_email } }
      put :update, params: params

      researcher.reload
      expect(researcher.email).to eq(new_email)
    end

    it 'does not update attributes when required fields are empty strings' do
      params = { id: researcher.id, researcher: { email: '' } }
      put :update, params: params

      researcher.reload
      expect(researcher.email).to eq(old_email)
    end
  end
end
