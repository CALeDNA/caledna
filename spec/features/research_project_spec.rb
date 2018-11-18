# frozen_string_literal: true

require 'rails_helper'

describe 'Research Project' do
  describe 'Pillar Point' do
    let(:project) do
      create(:research_project, slug: 'pillar-point', name: 'Pillar Point')
    end

    context 'when visitor is a guest' do
      it 'shows content for intro' do
        visit research_project_path(id: project.slug)

        expect(page).to have_content project.name
      end
    end

    context 'when vistor is logged-in user' do
      it 'shows content for intro' do
        visit research_project_path(id: project.slug)

        expect(page).to have_content project.name
      end
    end

    context 'when vistor is logged-in researcher' do
      before { login_director }
      it 'shows content for intro' do
        visit research_project_path(id: project.slug)

        expect(page).to have_content project.name
      end

      it 'shows content for list view' do
        visit research_project_path(id: project.slug, view: :list)

        expect(page).to have_content project.name
      end

      it 'shows content for occurrence_comparsion section' do
        visit research_project_path(id: project.slug,
                                    section: 'occurrence_comparsion')

        expect(page).to have_content project.name
      end

      it 'shows content for gbif_breakdown section' do
        visit research_project_path(id: project.slug,
                                    section: 'gbif_breakdown')

        expect(page).to have_content project.name
      end

      it 'shows content for edna_gbif_comparison section' do
        visit research_project_path(id: project.slug,
                                    section: 'edna_gbif_comparison')

        expect(page).to have_content project.name
      end

      it 'shows content for interactions section' do
        visit research_project_path(id: project.slug,
                                    section: 'interactions')

        expect(page).to have_content project.name
      end
    end
  end
end
