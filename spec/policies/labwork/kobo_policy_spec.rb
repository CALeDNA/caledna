# frozen_string_literal: true

require 'rails_helper'

describe Labwork::KoboPolicy do
  subject { described_class }
  let(:director) { create(:director) }
  let(:esie_postdoc) { create(:esie_postdoc) }
  let(:researcher) { create(:researcher) }
  let(:users) do
    [director, esie_postdoc, researcher]
  end

  permissions :import? do
    it 'grant access to all users' do
      users.each do |user|
        expect(subject).to permit(user)
      end
    end
  end
end
