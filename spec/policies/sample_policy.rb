# frozen_string_literal: true

require 'rails_helper'

describe SamplePolicy do
  subject { described_class }
  let(:director) { create(:director) }
  let(:lab_manager) { create(:lab_manager) }
  let(:sample_processor) { create(:sample_processor) }
  let(:users) do
    [director, lab_manager, sample_processor]
  end
  let(:non_directors) do
    [lab_manager, sample_processor]
  end

  permissions :index? do
    it 'grants access to all users' do
      users.each do |user|
        expect(subject).to permit(user, Sample.new)
      end
    end
  end

  permissions :show? do
    it 'grants access to all users' do
      users.each do |user|
        expect(subject).to permit(user, Sample.new)
      end
    end
  end

  permissions :create? do
    it 'grants access to directors' do
      expect(subject).to permit(director, Sample.new)
    end

    it 'denies access to non-directors' do
      non_directors.each do |user|
        expect(subject).to_not permit(user, Sample.new)
      end
    end
  end

  permissions :update? do
    it 'grants access to all users' do
      users.each do |user|
        expect(subject).to permit(user, Sample.new)
      end
    end
  end

  permissions :destroy? do
    it 'grants access to directors' do
      expect(subject).to permit(director, Sample.new)
    end

    it 'denies access to non-directors' do
      non_directors.each do |user|
        expect(subject).to_not permit(user, Sample.new)
      end
    end
  end
end
