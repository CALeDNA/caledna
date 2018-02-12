# frozen_string_literal: true

require 'rails_helper'

describe 'Samples' do
  describe 'samples index page' do
    let(:project) { create(:field_data_project) }
    let!(:sample1) do
      create(:sample, barcode: 'sample 1', field_data_project: project,
                      status_cd: :approved)
    end
    let!(:sample2) do
      create(:sample, barcode: 'sample 2', field_data_project: project,
                      status_cd: :analyzed)
    end
    let!(:sample3) do
      create(:sample, barcode: 'sample 3', field_data_project: project,
                      status_cd: :results_completed)
    end
    let!(:sample4) do
      create(:sample, barcode: 'sample 4', status_cd: :analyzed)
    end
    let!(:sample5) do
      create(:sample, barcode: 'sample 5', status_cd: :results_completed)
    end
    let!(:sample6) do
      create(:sample, barcode: 'sample 6', status_cd: :submitted)
    end

    let!(:sample7) do
      create(:sample, barcode: 'sample 7', status_cd: :rejected)
    end

    it 'renders all approved samples when no query string' do
      visit samples_path(view: :list)

      expect(page).to have_content 'sample 1'
      expect(page).to have_content 'sample 2'
      expect(page).to have_content 'sample 3'
      expect(page).to have_content 'sample 4'
      expect(page).to have_content 'sample 5'
    end

    it 'does not render unapproved samples' do
      visit samples_path(view: :list)
      expect(page).to_not have_content 'sample 6'
      expect(page).to_not have_content 'sample 7'
    end

    it 'renders one sample when sample_id is in query string' do
      visit samples_path(view: :list, sample_id: sample1.id)

      expect(page).to have_content 'sample 1'
      expect(page).to_not have_content 'sample 2'
      expect(page).to_not have_content 'sample 3'
      expect(page).to_not have_content 'sample 4'
      expect(page).to_not have_content 'sample 5'
    end

    it 'renders samples for a project when project_id is in query string' do
      visit samples_path(view: :list, field_data_project_id: project.id)

      expect(page).to have_content 'sample 1'
      expect(page).to have_content 'sample 2'
      expect(page).to have_content 'sample 3'
      expect(page).to_not have_content 'sample 4'
      expect(page).to_not have_content 'sample 5'
    end

    it 'renders analyzed samples when status=analyzed is in query string' do
      visit samples_path(view: :list, status: :analyzed)

      expect(page).to_not have_content 'sample 1'
      expect(page).to have_content 'sample 2'
      expect(page).to_not have_content 'sample 3'
      expect(page).to have_content 'sample 4'
      expect(page).to_not have_content 'sample 5'
    end

    it 'renders samples when results when status=results_completed is '\
       'in query string' do
      visit samples_path(view: :list, status: :results_completed)

      expect(page).to_not have_content 'sample 1'
      expect(page).to_not have_content 'sample 2'
      expect(page).to have_content 'sample 3'
      expect(page).to_not have_content 'sample 4'
      expect(page).to have_content 'sample 5'
    end

    it 'renders analyzed samples for a project when period_id and '\
       'status=analyzed are in query string' do
      visit samples_path(view: :list,
                         status: :analyzed,
                         field_data_project_id: project.id)

      expect(page).to_not have_content 'sample 1'
      expect(page).to have_content 'sample 2'
      expect(page).to_not have_content 'sample 3'
      expect(page).to_not have_content 'sample 4'
      expect(page).to_not have_content 'sample 5'
    end

    it 'renders analyzed samples for a project when period_id and '\
       'status=results_completed are in query string' do
      visit samples_path(view: :list,
                         status: :results_completed,
                         field_data_project_id: project.id)

      expect(page).to_not have_content 'sample 1'
      expect(page).to_not have_content 'sample 2'
      expect(page).to have_content 'sample 3'
      expect(page).to_not have_content 'sample 4'
      expect(page).to_not have_content 'sample 5'
    end
  end
end
