# frozen_string_literal: true

require 'rails_helper'

describe Page do
  describe '#menu_display' do
    context 'menu_text is available' do
      it 'returns menu_text' do
        page = create(:page, menu_text: 'menu_text', slug: 'slug')

        expect(page.menu_display).to eq('menu_text')
      end
    end

    context 'menu_text is not available' do
      it 'return slug' do
        page = create(:page, menu_text: nil, slug: 'Slug')

        expect(page.menu_display).to eq('Slug')
      end

      it 'returns titleized slug' do
        page = create(:page, menu_text: nil, slug: 'SlUg')

        expect(page.menu_display).to eq('Slug')
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
