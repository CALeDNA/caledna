# frozen_string_literal: true

require 'rails_helper'

describe ResearchProject do
  describe '#show_pages?' do
    it 'returns true if research project has any published pages' do
      project = create(:research_project)
      create(:page, published: true, research_project: project)
      create(:page, published: false, research_project: project)

      expect(project.show_pages?).to eq(true)
    end

    it 'returns false if research project has all unpublished pages' do
      project = create(:research_project)
      create(:page, published: false, research_project: project)

      expect(project.show_pages?).to eq(false)
    end

    it 'returns false if research project has no pages' do
      project = create(:research_project)

      expect(project.show_pages?).to eq(false)
    end
  end

  describe '#default_page' do
    it 'returns nil if project does not have pages' do
      project = create(:research_project)

      expect(project.default_page).to eq(nil)
    end

    it 'return the first published page sorted by display order' do
      project = create(:research_project)
      create(:page, published: true, research_project: project,
                    display_order: 2)
      page = create(:page, published: true, research_project: project,
                           display_order: 1)
      create(:page, published: true, research_project: project,
                    display_order: 3)

      expect(project.default_page).to eq(page)
    end

    it 'ignores unpublished pages' do
      project = create(:research_project)
      create(:page, published: false, research_project: project,
                    display_order: 1)
      create(:page, published: false, research_project: project,
                    display_order: 2)

      expect(project.default_page).to eq(nil)
    end

    it 'returns first created published page if no display order is set' do
      project = create(:research_project)
      page = create(:page, published: true, research_project: project)
      create(:page, published: true, research_project: project)

      expect(project.default_page).to eq(page)
    end

    it 'sorts null display_order lasts' do
      project = create(:research_project)

      create(:page, published: true, research_project: project)
      create(:page, published: true, research_project: project,
                    display_order: 2)
      page = create(:page, published: true, research_project: project,
                           display_order: 1)

      expect(project.default_page).to eq(page)
    end
  end

  describe '#project_pages' do
    it 'returns empty array if project does not have pages' do
      project = create(:research_project)

      expect(project.project_pages).to eq([])
    end

    it 'returns published page sorted by display order' do
      project = create(:research_project)
      page2 = create(:page, published: true, research_project: project,
                            display_order: 2)
      page1 = create(:page, published: true, research_project: project,
                            display_order: 1)
      page3 = create(:page, published: true, research_project: project,
                            display_order: 3)

      expect(project.project_pages).to eq([page1, page2, page3])
    end

    it 'ignores unpublished pages' do
      project = create(:research_project)
      create(:page, published: false, research_project: project,
                    display_order: 1)
      create(:page, published: false, research_project: project,
                    display_order: 2)

      expect(project.project_pages).to eq([])
    end

    it 'returns first created published page if no display order is set' do
      project = create(:research_project)
      page1 = create(:page, published: true, research_project: project)
      page2 = create(:page, published: true, research_project: project)

      expect(project.project_pages).to eq([page1, page2])
    end

    it 'sorts null display_order lasts' do
      project = create(:research_project)

      page3 = create(:page, published: true, research_project: project)
      page2 = create(:page, published: true, research_project: project,
                            display_order: 2)
      page1 = create(:page, published: true, research_project: project,
                            display_order: 1)

      expect(project.project_pages).to eq([page1, page2, page3])
    end
  end
end
