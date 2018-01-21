# frozen_string_literal: true

require 'rails_helper'

describe 'Maps' do
  describe 'maps show page' do
    let(:project) { create(:project, name: 'project 1') }
    let!(:sample1) do
      create(:sample, bar_code: 'sample 1', project: project)
    end
    let!(:sample2) do
      create(:sample, bar_code: 'sample 2', project: project)
    end

    it 'renders all samples when no query string' do
      visit samples_path
      expect(page).to have_content 'sample 1'
      expect(page).to have_content 'sample 2'
      expect(page).to have_content 'project 1'
    end
  end
end
