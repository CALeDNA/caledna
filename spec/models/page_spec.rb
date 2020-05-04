# frozen_string_literal: true

require 'rails_helper'

describe Page do
  describe 'validations' do
    describe '#unique_slugs' do
      before do
        stub_const('Website::DEFAULT_SITE', create(:website, name: 'demo'))
      end

      let(:site) { Website::DEFAULT_SITE }

      context 'when there are research project and normal pages' do
        it 'returns true if research page slug is unique' do
          project = create(:research_project)

          create(:page, slug: 'slug')
          page = build(:page, slug: 'slug', research_project: project,
                              website: site)

          expect(page.valid?).to eq(true)
        end

        it 'returns true if page slug is unique' do
          project = create(:research_project)
          create(:page, slug: 'slug', research_project: project, website: site)
          page = build(:page, slug: 'slug')

          expect(page.valid?).to eq(true)
        end
      end

      context 'when page is for research project' do
        it 'returns true if slug is unique for the research project' do
          project = create(:research_project)
          create(:page, slug: 'slug1', research_project: project, website: site)
          page = build(:page, slug: 'slug2', research_project: project,
                              website: site)

          expect(page.valid?).to eq(true)
        end

        it 'returns true if two different projects have same slug' do
          project = create(:research_project)
          create(:page, slug: 'slug1', research_project: project, website: site)

          project2 = create(:research_project)
          page = build(:page, slug: 'slug1', research_project: project2,
                              website: site)

          expect(page.valid?).to eq(true)
        end

        it 'returns false if slug is not unique for the research project' do
          project = create(:research_project)
          create(:page, slug: 'slug', research_project: project, website: site)
          page = build(:page, slug: 'slug', research_project: project,
                              website: site)

          expect(page.valid?).to eq(false)
          expect(page.errors.messages[:slug]).to eq(['has already been taken'])
        end
      end

      context 'when pages are for different sites' do
        it 'returns true if slug is unique to a site' do
          create(:page, slug: 'slug1', website: site)
          page = build(:page, slug: 'slug2', website: site)

          expect(page.valid?).to eq(true)
        end

        it 'returns false if slug is not unique to a site' do
          website = site
          create(:page, slug: 'slug', website: website)
          page = build(:page, slug: 'slug', website: website)

          expect(page.valid?).to eq(false)
          expect(page.errors.messages[:slug]).to eq(['has already been taken'])
        end
      end

      context 'when page is not for research project' do
        let(:website) { site }

        it 'returns true if slug is unique' do
          create(:page, slug: 'slug1', website: site)
          page = build(:page, slug: 'slug2', website: site)

          expect(page.valid?).to eq(true)
        end

        it 'returns false if slug is not unique' do
          create(:page, slug: 'slug', website: site)
          page = build(:page, slug: 'slug', website: site)

          expect(page.valid?).to eq(false)
          expect(page.errors.messages[:slug]).to eq(['has already been taken'])
        end
      end

      context 'when pages is updated' do
        it 'returns true if slug is unique' do
          page = create(:page, slug: 'slug1', website: site)
          page.update(body: 'body')

          expect(page.valid?).to eq(true)
        end
      end
    end
  end

  describe '#menu_display' do
    context 'menu_text is available' do
      it 'returns menu_text' do
        page = create(:page, menu_text: 'menu_text', slug: 'slug')

        expect(page.menu_display).to eq('menu_text')
      end
    end

    context 'menu_text is not available' do
      it 'returns title' do
        page = create(:page, menu_text: nil, title: 'Page Title')

        expect(page.menu_text).to eq(nil)
        expect(page.menu_display).to eq('Page Title')
      end
    end
  end

  describe '#show_edit_link?' do
    context 'when page is a normal page' do
      let(:page) { create(:page) }

      it 'returns true if user is director' do
        user = create(:director)

        expect(page.show_edit_link?(user)).to eq(true)
      end

      it 'returns true if user is superadmin' do
        user = create(:superadmin)

        expect(page.show_edit_link?(user)).to eq(true)
      end

      it 'returns false researchers' do
        user = create(:researcher)

        expect(page.show_edit_link?(user)).to eq(false)
      end

      it 'returns false if no user' do
        user = nil

        expect(page.show_edit_link?(user)).to eq(false)
      end
    end

    context 'when page is a research project page' do
      let(:project) { create(:research_project) }
      let(:page) { create(:page, research_project: project) }

      it 'returns true if user is director' do
        user = create(:director)

        expect(page.show_edit_link?(user)).to eq(true)
      end

      it 'returns true if user is superadmin' do
        user = create(:superadmin)

        expect(page.show_edit_link?(user)).to eq(true)
      end

      it 'returns true if user is an author of the page' do
        user = create(:researcher)
        create(:research_project_author, authorable: user,
                                         research_project_id: project.id)

        expect(page.show_edit_link?(user)).to eq(true)
      end

      it 'returns false for researchers' do
        user = create(:researcher)

        expect(page.show_edit_link?(user)).to eq(false)
      end

      it 'returns false if no user' do
        user = nil

        expect(page.show_edit_link?(user)).to eq(false)
      end
    end
  end
end
