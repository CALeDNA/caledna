# frozen_string_literal: true

require 'rails_helper'

describe ImportKoboPolicy do
  subject { described_class }
  let(:director) { create(:director) }
  let(:lab_manager) { create(:lab_manager) }
  let(:sample_processor) { create(:sample_processor) }
  let(:non_directors) do
    [lab_manager, sample_processor]
  end

  permissions :import_kobo? do
    it 'grants access to directors' do
      expect(subject).to permit(director)
    end

    it 'denies access to non-directors' do
      non_directors.each do |user|
        expect(subject).to_not permit(user)
      end
    end
  end

  permissions :import_projects? do
    it 'grants access to directors' do
      expect(subject).to permit(director)
    end

    it 'denies access to non-directors' do
      non_directors.each do |user|
        expect(subject).to_not permit(user)
      end
    end
  end

  permissions :import_samples? do
    it 'grants access to directors' do
      expect(subject).to permit(director)
    end

    it 'denies access to non-directors' do
      non_directors.each do |user|
        expect(subject).to_not permit(user)
      end
    end
  end
end
