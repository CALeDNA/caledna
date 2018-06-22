# frozen_string_literal: true

FactoryBot.define do
  factory :event do
    name 'Event name'
    start_date { Time.zone.now + 7.days }
    description 'description'
    end_date { Time.zone.now + 8.days }
  end
end
