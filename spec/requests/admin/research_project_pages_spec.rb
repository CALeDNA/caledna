# frozen_string_literal: true

require 'rails_helper'

describe 'ResearchProjectPages' do
  describe '#GET pages index page' do
    let!(:project) { create(:research_project) }
    let!(:project2) { create(:research_project) }
    let!(:page1) do
      create(:research_project_page, title: 'research1',
                                     research_project: project)
    end
    let!(:page2) do
      create(:research_project_page, title: 'my research2',
                                     research_project: project2)
    end

    shared_examples 'index page status' do
      it 'returns 200' do
        get admin_research_project_pages_path

        expect(response.status).to eq(200)
      end
    end

    context 'when superadmin' do
      before { login_for(user) }

      let(:user) { create(:superadmin) }

      include_examples 'index page status'

      it 'display all pages' do
        create(:research_project_author, authorable: user,
                                         research_project: project2)

        get admin_research_project_pages_path

        expect(response.body).to include('research1')
        expect(response.body).to include('my research2')
      end
    end

    context 'when director' do
      before { login_for(user) }

      let(:user) { create(:director) }

      include_examples 'index page status'

      it 'display all pages for this site' do
        create(:research_project_author, authorable: user,
                                         research_project: project2)

        get admin_research_project_pages_path

        expect(response.body).to include('research1')
        expect(response.body).to include('my research2')
      end
    end

    context 'when esie_postdoc' do
      before { login_for(user) }

      let(:user) { create(:esie_postdoc) }

      include_examples 'index page status'

      it 'display all research pages' do
        create(:research_project_author, authorable: user,
                                         research_project: project2)

        get admin_research_project_pages_path

        expect(response.body).to include('research1')
        expect(response.body).to include('my research2')
      end
    end

    context 'when reseacher' do
      before { login_for(user) }

      let(:user) { create(:researcher) }

      include_examples 'index page status'

      it 'display research pages from user' do
        create(:research_project_author, authorable: user,
                                         research_project: project2)

        get admin_research_project_pages_path

        expect(response.body).to_not include('research1')
        expect(response.body).to include('my research2')
      end
    end
  end
end
