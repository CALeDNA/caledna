# frozen_string_literal: true

require 'rails_helper'

describe ResearchProjectPage do
  describe 'validations' do
    describe '#unique_slugs' do
      context 'when page is for research project' do
        it 'returns true if slug is unique for the research project' do
          project = create(:research_project)
          create(:research_project_page, slug: 'slug1',
                                         research_project: project)
          page = build(:research_project_page, slug: 'slug2',
                                               research_project: project)

          expect(page.valid?).to eq(true)
        end

        it 'returns true if two different projects have same slug' do
          project = create(:research_project)
          create(:research_project_page, slug: 'slug1',
                                         research_project: project)

          project2 = create(:research_project)
          page = build(:research_project_page, slug: 'slug1',
                                               research_project: project2)

          expect(page.valid?).to eq(true)
        end

        it 'returns false if slug is not unique for the research project' do
          project = create(:research_project)
          create(:research_project_page, slug: 'slug',
                                         research_project: project)
          page = build(:research_project_page, slug: 'slug',
                                               research_project: project)

          expect(page.valid?).to eq(false)
          expect(page.errors.messages[:slug]).to eq(['has already been taken'])
        end
      end

      context 'when pages is updated' do
        it 'returns true if slug is unique' do
          project = create(:research_project)
          page = create(:research_project_page, slug: 'slug1',
                                                research_project: project)
          page.update(body: 'body')

          expect(page.valid?).to eq(true)
        end
      end
    end
  end

  describe '#show_edit_link?' do
    context 'when page is a normal page' do
      let(:page) do
        create(:research_project_page,
               research_project: create(:research_project))
      end

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
      let(:page) { create(:research_project_page, research_project: project) }

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
