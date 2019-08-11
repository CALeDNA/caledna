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
    it 'returns OK when sample is approved' do
      sample = create(:sample, status_cd: :approved, latitude: 1, longitude: 1,
                               kobo_data: {})
      get sample_path(id: sample.id)

      expect(response.status).to eq(200)
    end

    it 'raises an error if sample is not approved' do
      sample = create(:sample, status_cd: :submitted, latitude: 1, longitude: 1)

      expect { get sample_path(id: sample.id) }
        .to raise_error(ActiveRecord::RecordNotFound)
    end

    it 'raises an error for invalid id' do
      expect { get sample_path(id: 1) }
        .to raise_error(ActiveRecord::RecordNotFound)
    end
  end
end
