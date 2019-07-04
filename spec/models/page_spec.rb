# frozen_string_literal: true

require 'rails_helper'

describe Page do
  describe 'validations' do
    describe '#unique_slugs' do
      context 'when there are research project and normal pages' do
        it 'returns true if research page slug is unique' do
          project = create(:research_project)
          create(:page, slug: 'slug')
          page = build(:page, slug: 'slug', research_project: project)

          expect(page.valid?).to eq(true)
        end

        it 'returns true if page slug is unique' do
          project = create(:research_project)
          create(:page, slug: 'slug', research_project: project)
          page = build(:page, slug: 'slug')

          expect(page.valid?).to eq(true)
        end
      end

      context 'when page is for research project' do
        it 'returns true if slug is unique for the research project' do
          project = create(:research_project)
          create(:page, slug: 'slug1', research_project: project)
          page = build(:page, slug: 'slug2', research_project: project)

          expect(page.valid?).to eq(true)
        end

        it 'returns false if slug is not unique for the research project' do
          project = create(:research_project)
          create(:page, slug: 'slug', research_project: project)
          page = build(:page, slug: 'slug', research_project: project)

          expect(page.valid?).to eq(false)
          expect(page.errors.messages[:slug]).to eq(['has already been taken'])
        end
      end

      context 'when page is not for research project' do
        it 'returns true if slug is unique' do
          create(:page, slug: 'slug1')
          page = build(:page, slug: 'slug2')

          expect(page.valid?).to eq(true)
        end

        it 'returns false if slug is not unique' do
          create(:page, slug: 'slug')
          page = build(:page, slug: 'slug')

          expect(page.valid?).to eq(false)
          expect(page.errors.messages[:slug]).to eq(['has already been taken'])
        end
      end
    end
  end

  describe 'before save: set_slug' do
    it 'adds a slug using the page title if no slug is given' do
      page = create(:page, title: 'My Page', slug: nil)

      expect(page.slug).to eq('my-page')
    end

    it 'does nothing is slug is given' do
      page = create(:page, title: 'My Page', slug: 'my-slug')

      expect(page.slug).to eq('my-slug')
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

  describe '#show_project_map?' do
    context 'when page does not have research project' do
      it 'returns false' do
        page = create(:page, research_project: nil)

        expect(page.show_project_map?).to eq(false)
      end
    end

    context 'when page does not have research project' do
      it 'returns true when page if default project page' do
        project = create(:research_project)
        page = create(:page, research_project: project)
        project.stub(:default_page) { page }

        expect(page.show_project_map?).to eq(true)
      end

      it 'returns false otherwise' do
        project = create(:research_project)
        page1 = create(:page, research_project: project)
        page = create(:page, research_project: project)
        project.stub(:default_page) { page1 }

        expect(page.show_project_map?).to eq(false)
      end
    end
  end
end
