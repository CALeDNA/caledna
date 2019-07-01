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
        slug: 'page-slug',
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
      create(:research_project, slug: 'project-slug', name: 'project name')
    end

    let!(:project_page_1) do
      create(
        :page,
        research_project: project,
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
        research_project: project,
        published: true,
        title: 'page title 2',
        slug: 'page-slug-2',
        body: 'page body 2',
        menu: 'page menu text 2',
        display_order: 2
      )
    end

    context 'when visiting project home page' do
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

      it 'displays page content' do
        visit research_project_path(id: project.slug)

        expect(page).to have_content project_page_1.title
        expect(page).to have_content project_page_1.body
      end
    end

    context 'when visiting project default page' do
      it 'displays has submenu' do
        visit research_project_page_path(research_project_id: project.slug,
                                         id: project_page_1.slug)

        expect(page).to have_content project_page_1.menu_text
      end

      it 'displays project name' do
        visit research_project_page_path(research_project_id: project.slug,
                                         id: project_page_1.slug)

        expect(page).to have_content project.name
      end

      it 'displays map' do
        visit research_project_page_path(research_project_id: project.slug,
                                         id: project_page_1.slug)

        expect(page).to have_content 'Map Layers'
      end

      it 'displays page content' do
        visit research_project_page_path(research_project_id: project.slug,
                                         id: project_page_1.slug)

        expect(page).to have_content project_page_1.title
        expect(page).to have_content project_page_1.body
      end
    end

    context 'when visiting project other pages' do
      it 'displays has submenu' do
        visit research_project_page_path(research_project_id: project.slug,
                                         id: project_page_2.slug)

        expect(page).to have_content project_page_2.menu_text
      end

      it 'displays project name' do
        visit research_project_page_path(research_project_id: project.slug,
                                         id: project_page_2.slug)

        expect(page).to have_content project.name
      end

      it 'does not display map' do
        visit research_project_page_path(research_project_id: project.slug,
                                         id: project_page_2.slug)

        expect(page).not_to have_content 'Map Layers'
      end

      it 'displays page content' do
        visit research_project_page_path(research_project_id: project.slug,
                                         id: project_page_2.slug)

        expect(page).to have_content project_page_2.title
        expect(page).to have_content project_page_2.body
      end
    end
  end

  context 'Pillar Point' do
    let(:project) do
      create(:research_project, slug: 'pillar-point', name: 'Pillar Point')
    end

    let!(:project_page) do
      create(:page, research_project: project, published: true,
                    title: 'page title', slug: 'pillar-point/intro')
    end

    it 'shows content for intro' do
      visit research_project_path(id: project.slug)

      expect(page).to have_content project.name
      expect(page).to have_content project_page.title
    end

    it 'shows content for list view' do
      visit research_project_path(id: project.slug, view: :list)

      expect(page).to have_content project.name
      expect(page).to have_content project_page.title
    end

    it 'shows content for named sections' do
      project_page.update(slug: 'pillar-point/section_name')

      visit research_project_path(id: project.slug,
                                  section: 'section_name')

      expect(page).to have_content project.name
      expect(page).to have_content project_page.title
    end

    it 'shows submenu' do
      visit research_project_path(id: project.slug)

      expect(page).to have_content 'Intro'
      expect(page).to have_content 'Occurrence Comparison'
      expect(page).to have_content 'GBIF Sources'
      expect(page).to have_content 'GBIF Taxonomy'
      expect(page).to have_content 'Common Taxa'
      expect(page).to have_content 'Area Diversity'
      expect(page).to have_content 'Taxonomy Comparison'
      expect(page).to have_content 'Detection Frequency'
      expect(page).to have_content 'Networks'
      expect(page).to have_content 'Biotic Interactions'
    end
  end
end
