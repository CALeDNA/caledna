# frozen_string_literal: true

require 'rails_helper'

describe 'Events' do
  describe 'events index page' do
    it 'returns OK' do
      get events_path

      expect(response.status).to eq(200)
    end
  end

  describe 'events show page' do
    it 'returns OK' do
      event = create(:event)
      get event_path(id: event.id)

      expect(response.status).to eq(200)
    end

    it 'raises an error for invalid id' do
      expect { get event_path(id: 1) }
        .to raise_error(ActiveRecord::RecordNotFound)
    end
  end
end
