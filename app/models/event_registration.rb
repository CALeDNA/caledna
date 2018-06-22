# frozen_string_literal: true

class EventRegistration < ApplicationRecord
  belongs_to :user
  belongs_to :event

  as_enum :status, %i[registered canceled attended no_show], map: :string

  validates :user_id, uniqueness: {
    scope: :event_id,
    message: 'You already registered for this event.'
  }
end
