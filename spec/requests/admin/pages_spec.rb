# frozen_string_literal: true

require 'rails_helper'

describe 'Samples' do
  describe '#GET pages index page' do
    before do
      stub_const('Website::DEFAULT_SITE', create(:website, name: 'demo'))
    end

    let!(:project) { create(:research_project) }
    let!(:project2) { create(:research_project) }
    let!(:page1) { create(:page, title: 'normal', website: website) }
    let!(:page2) do
      create(:page, title: 'research1', research_project: project,
                    website: website)
    end
    let!(:page3) do
      create(:page, title: 'my research2', research_project: project2,
                    website: website)
    end
    let!(:page4) { create(:page, title: 'other', website: create(:website)) }
    let(:website) { Website::DEFAULT_SITE }

    shared_examples 'index page status' do
      it 'returns 200' do
        get admin_pages_path

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

        get admin_pages_path

        expect(response.body).to include('normal')
        expect(response.body).to include('research1')
        expect(response.body).to include('my research2')
        expect(response.body).to include('other')
      end
    end

    context 'when director' do
      before { login_for(user) }

      let(:user) { create(:director) }

      include_examples 'index page status'

      it 'display all pages for this site' do
        create(:research_project_author, authorable: user,
                                         research_project: project2)

        get admin_pages_path

        expect(response.body).to include('normal')
        expect(response.body).to include('research1')
        expect(response.body).to include('my research2')
        expect(response.body).to_not include('other')
      end
    end

    context 'when esie_postdoc' do
      before { login_for(user) }

      let(:user) { create(:esie_postdoc) }

      include_examples 'index page status'

      it 'display all research pages' do
        create(:research_project_author, authorable: user,
                                         research_project: project2)

        get admin_pages_path

        expect(response.body).to_not include('normal')
        expect(response.body).to include('research1')
        expect(response.body).to include('my research2')
        expect(response.body).to_not include('other')
      end
    end

    context 'when reseacher' do
      before { login_for(user) }

      let(:user) { create(:researcher) }

      include_examples 'index page status'

      it 'display research pages from user' do
        create(:research_project_author, authorable: user,
                                         research_project: project2)

        get admin_pages_path

        expect(response.body).to_not include('normal')
        expect(response.body).to_not include('research1')
        expect(response.body).to include('my research2')
        expect(response.body).to_not include('other')
      end
    end
  end
end
