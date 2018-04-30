# frozen_string_literal: true

require 'rails_helper'

describe 'Samples' do
  describe 'samples index page' do
    it 'returns OK' do
      get samples_path

      expect(response.status).to eq(200)
    end
  end

  describe 'samples show page' do
    # TODO: enable test to work with webpacker
    it 'returns OK' do
      sample = create(:sample, status_cd: :approved)
      get sample_path(id: sample.id)

      expect(response.status).to eq(200)
    end
  end
end
