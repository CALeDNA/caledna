# frozen_string_literal: true

require 'rails_helper'

describe 'Samples' do
  describe '#GET pages index page' do
    let!(:project) { create(:research_project) }
    let!(:project2) { create(:research_project) }
    let!(:page1) { create(:page, title: 'normal') }
    let!(:page2) do
      create(:page, title: 'research1', research_project: project)
    end
    let!(:page3) do
      create(:page, title: 'my research2', research_project: project2)
    end

    context 'when director' do
      let(:user) { create(:director) }

      it 'returns 200' do
        login_for(user)
        get admin_pages_path

        expect(response.status).to eq(200)
      end

      it 'display all pages' do
        create(:research_project_author, authorable: user,
                                         research_project: project2)

        login_for(user)
        get admin_pages_path

        expect(response.body).to include('normal')
        expect(response.body).to include('research1')
        expect(response.body).to include('my research2')
      end
    end

    context 'when esie_postdoc' do
      let(:user) { create(:esie_postdoc) }

      it 'returns 200' do
        login_for(user)
        get admin_pages_path

        expect(response.status).to eq(200)
      end

      it 'display all research pages' do
        create(:research_project_author, authorable: user,
                                         research_project: project2)

        login_for(user)
        get admin_pages_path

        expect(response.body).to_not include('normal')
        expect(response.body).to include('research1')
        expect(response.body).to include('my research2')
      end
    end

    context 'when reseacher' do
      let(:user) { create(:researcher) }

      it 'returns 200' do
        login_for(user)
        get admin_pages_path

        expect(response.status).to eq(200)
      end

      it 'display research pages from user' do
        create(:research_project_author, authorable: user,
                                         research_project: project2)

        login_for(user)
        get admin_pages_path

        expect(response.body).to_not include('normal')
        expect(response.body).to_not include('research1')
        expect(response.body).to include('my research2')
      end
    end
  end
end
