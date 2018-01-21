# frozen_string_literal: true

require 'rails_helper'

describe 'Maps' do
  describe 'maps show page' do
    it 'returns OK' do
      get map_path

      expect(response.status).to eq(200)
    end
  end
end
