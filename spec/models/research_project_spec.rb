# frozen_string_literal: true

require 'rails_helper'

describe ResearchProject do
  describe 'validations' do
    it 'returns true if slug is unique' do
      create(:research_project, slug: 'slug1')
      project = build(:research_project, slug: 'slug2')

      expect(project.valid?).to eq(true)
    end

    it 'returns false if slug is not unique' do
      create(:research_project, slug: 'slug')
      project = build(:research_project, slug: 'slug')

      expect(project.valid?).to eq(false)
      expect(project.errors.messages[:slug]).to eq(['has already been taken'])
    end
  end

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

  describe '#researcher_authors' do
    it 'returns researchers who are authors for a research project' do
      project1 = create(:research_project)
      researcher1 = create(:researcher)
      create(:researcher)
      create(:research_project_author, research_project: project1,
                                       authorable: researcher1)

      expect(project1.researcher_authors).to eq([researcher1])
    end
  end

  describe '#user_authors' do
    it 'returns users who are authors for a research project' do
      project1 = create(:research_project)
      user1 = create(:user)
      create(:user)
      create(:research_project_author, research_project: project1,
                                       authorable: user1)

      expect(project1.user_authors).to eq([user1])
    end
  end

  describe '#primers' do
    it 'returns an array of unique primers for this project' do
      project = create(:research_project)
      sample1 = create(:sample)
      sample2 = create(:sample)
      primer1 = create(:primer)
      primer2 = create(:primer)
      create(:sample_primer, sample: sample1, primer: primer1,
                             research_project: project)
      create(:sample_primer, sample: sample1, primer: primer2,
                             research_project: project)
      create(:sample_primer, sample: sample2, primer: primer2,
                             research_project: project)

      expect(project.primers).to match_array([primer2, primer1])
    end

    it 'ignores primers for other projects' do
      project = create(:research_project)
      project2 = create(:research_project)
      sample1 = create(:sample)
      primer1 = create(:primer)
      create(:sample_primer, sample: sample1, primer: primer1,
                             research_project: project2)

      expect(project.primers).to match_array([])
    end
  end
end
