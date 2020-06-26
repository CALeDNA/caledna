# frozen_string_literal: true

require 'rails_helper'

describe 'Researcher' do
  shared_examples 'allows read access' do
    describe '#GET researchers index page' do
      xit 'returns 200' do
        create(:researcher, username: 'name1')
        get admin_researchers_path

        expect(response.status).to eq(200)
      end
    end

    describe '#GET researchers show page' do
      xit 'returns 200' do
        researcher = create(:researcher, username: 'name1')
        get admin_researcher_path(id: researcher.id)

        expect(response.status).to eq(200)
      end
    end
  end

  shared_examples 'allows write access' do
    describe '#GET researchers new page' do
      xit 'returns 200' do
        get new_admin_researcher_path

        expect(response.status).to eq(200)
      end
    end

    describe '#GET researchers edit page' do
      xit 'returns 200' do
        researcher = create(:researcher, username: 'name1')
        get edit_admin_researcher_path(id: researcher.id)

        expect(response.status).to eq(200)
      end
    end

    describe '#POST' do
      xit 'creates a new researcher' do
        attributes = FactoryBot.attributes_for(:researcher)
        params = { researcher: attributes }

        expect { post admin_researchers_path, params: params }
          .to change(Researcher, :count).by(1)
      end
    end

    describe '#PUT' do
      xit 'updates a researcher' do
        researcher = FactoryBot.create(:researcher, username: 'name1')
        params = { id: researcher.id, researcher: { username: 'name2' } }
        put admin_researcher_path(id: researcher.id), params: params
        researcher.reload

        expect(researcher.username).to eq('name2')
      end
    end

    describe '#DELETE' do
      xit 'deletes a researcher' do
        researcher = FactoryBot.create(:researcher)

        expect { delete admin_researcher_path(id: researcher.id) }
          .to change(Researcher, :count).by(-1)
      end
    end
  end

  shared_examples 'allows read access to #index' do
    describe '#GET researchers index page' do
      xit 'returns 200' do
        create(:researcher, username: 'name1')
        get admin_researchers_path

        expect(response.status).to eq(200)
      end
    end
  end

  shared_examples 'denies read access to #show' do
    describe '#GET researchers show page' do
      xit 'returns 302' do
        researcher = create(:researcher, username: 'name1')
        get admin_researcher_path(id: researcher.id)

        expect(response.status).to eq(302)
      end
    end
  end

  shared_examples 'denies write access' do
    describe '#GET researchers new page' do
      xit 'redirects to admin root' do
        get new_admin_sample_path

        expect(response).to redirect_to admin_samples_path
      end
    end

    describe '#GET researchers edit page' do
      xit 'redirects to admin root' do
        researcher = create(:researcher, username: 'name1')
        get edit_admin_researcher_path(id: researcher.id)

        expect(response).to redirect_to admin_samples_path
      end
    end

    describe '#POST' do
      xit 'does not create a new researcher' do
        attributes = FactoryBot.attributes_for(:researcher)
        params = { researcher: attributes }

        expect { post admin_researchers_path, params: params }
          .to change(Researcher, :count).by(0)
      end
    end

    describe '#PUT' do
      xit 'does not update a researcher' do
        researcher = FactoryBot.create(:researcher, username: 'name1')
        params = { id: researcher.id, researcher: { username: 'name2' } }
        put admin_researcher_path(id: researcher.id), params: params
        researcher.reload

        expect(researcher.username).to eq('name1')
      end
    end

    describe '#DELETE' do
      xit 'does not delete a researcher' do
        researcher = FactoryBot.create(:researcher)

        expect { delete admin_researcher_path(id: researcher.id) }
          .to change(Researcher, :count).by(0)
      end
    end
  end

  describe 'when researcher is a director' do
    before { login_director }
    include_examples 'allows read access'
    include_examples 'allows write access'
  end

  describe 'when researcher is a esie_postdoc' do
    before { login_esie_postdoc }
    include_examples 'allows read access'
    include_examples 'denies write access'
  end

  describe 'when researcher is a researcher' do
    before { login_researcher }
    include_examples 'allows read access'
    include_examples 'denies write access'
  end
end
