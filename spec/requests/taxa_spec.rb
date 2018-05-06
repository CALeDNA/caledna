# frozen_string_literal: true

require 'rails_helper'

describe 'Taxa' do
  describe 'taxa index page' do
    it 'returns OK when there are no taxa' do
      get taxa_path

      expect(response.status).to eq(200)
    end

    it 'returns OK when there are taxa' do
      create(:taxon)
      get taxa_path

      expect(response.status).to eq(200)
    end
  end

  describe 'taxa show page' do
    it 'returns OK for valid id' do
      VCR.use_cassette 'taxa show' do
        taxon = create(:taxon, canonicalName: 'abc')
        get taxon_path(id: taxon.id)

        expect(response.status).to eq(200)
      end
    end

    it 'raises an error invalid id' do
      expect { get taxon_path(id: 1) }
        .to raise_error(ActiveRecord::RecordNotFound)
    end
  end
end
