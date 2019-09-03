# frozen_string_literal: true

require 'rails_helper'

describe 'Research Project' do
  context 'when project does not have published pages' do
    let(:project) do
      create(:research_project, slug: 'project-slug', name: 'project-name')
    end

    let!(:project_page) do
      create(
        :page,
        research_project: project,
        published: false,
        title: 'page title',
        slug: 'page-slug-default',
        body: 'page body',
        menu_text: 'page menu text'
      )
    end

    it 'displays project name' do
      visit research_project_path(id: project.slug)

      expect(page).to have_content project.name
    end

    it 'displays map' do
      visit research_project_path(id: project.slug)

      expect(page).to have_content 'Map Layers'
    end

    it 'does not display submenu' do
      visit research_project_path(id: project.slug)

      expect(page).not_to have_content project_page.menu_text
    end

    it 'does not display page content' do
      visit research_project_path(id: project.slug)

      expect(page).not_to have_content project_page.title
      expect(page).not_to have_content project_page.body
    end
  end

  context 'when project does have published pages' do
    let(:project) do
      create(:research_project, slug: 'project-slug', name: 'project name 1')
    end

    let(:project_with_pages) do
      create(:research_project, slug: 'project-with-pages-slug',
                                name: 'project name 2')
    end

    let!(:project_page_1) do
      create(
        :page,
        research_project: project_with_pages,
        published: true,
        title: 'page title 1',
        slug: 'page-slug-1',
        body: 'page body 1',
        menu: 'page menu text 1',
        display_order: 1
      )
    end

    let!(:project_page_2) do
      create(
        :page,
        research_project: project_with_pages,
        published: true,
        title: 'page title 2',
        slug: 'page-slug-2',
        body: 'page body 2',
        menu: 'page menu text 2',
        display_order: 2
      )
    end

    context 'when visiting project without pages' do
      it 'displays submenu' do
        visit research_project_path(id: project.slug)

        expect(page).to have_content project_page_1.menu_text
      end

      it 'displays project name' do
        visit research_project_path(id: project.slug)

        expect(page).to have_content project.name
      end

      it 'displays map' do
        visit research_project_path(id: project.slug)

        expect(page).to have_content 'Map Layers'
      end
    end

    context 'when visiting project with pages' do
      it 'displays has submenu for first page' do
        visit research_project_page_path(
          research_project_id: project_with_pages.slug,
          id: project_page_1.slug
        )

        expect(page).to have_content project_page_1.menu_text
      end

      it 'displays project name' do
        visit research_project_page_path(
          research_project_id: project_with_pages.slug,
          id: project_page_1.slug
        )

        expect(page).to have_content project_with_pages.name
      end

      it 'does not displays map' do
        visit research_project_page_path(
          research_project_id: project_with_pages.slug,
          id: project_page_1.slug
        )

        expect(page).to_not have_content 'Map Layers'
      end

      it 'displays page content' do
        visit research_project_page_path(
          research_project_id: project_with_pages.slug,
          id: project_page_1.slug
        )

        expect(page).to have_content project_page_1.title
        expect(page).to have_content project_page_1.body
      end
    end

    context 'when visiting project with pages other pages' do
      it 'displays has submenu' do
        visit research_project_page_path(
          research_project_id: project_with_pages.slug,
          id: project_page_2.slug
        )

        expect(page).to have_content project_page_2.menu_text
      end

      it 'displays project name' do
        visit research_project_page_path(
          research_project_id: project_with_pages.slug,
          id: project_page_2.slug
        )

        expect(page).to have_content project_with_pages.name
      end

      it 'does not display map' do
        visit research_project_page_path(
          research_project_id: project_with_pages.slug,
          id: project_page_2.slug
        )

        expect(page).not_to have_content 'Map Layers'
      end

      it 'displays page content' do
        visit research_project_page_path(
          research_project_id: project_with_pages.slug,
          id: project_page_2.slug
        )

        expect(page).to have_content project_page_2.title
        expect(page).to have_content project_page_2.body
      end
    end
  end
end
