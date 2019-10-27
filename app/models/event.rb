# frozen_string_literal: true

class Event < ApplicationRecord
  belongs_to :field_project, optional: true
  has_one_attached :flyer
  has_many :event_registrations
  has_many :users, through: :event_registrations

  validates :name, :start_date, :end_date, :description, presence: true

  scope :upcoming, (lambda do
    where("end_date > '#{Time.zone.now}'").order(end_date: :desc)
  end)
  scope :past, (lambda do
    where("end_date < '#{Time.zone.now}'").order(end_date: :desc)
  end)

  def flyer?
    flyer.attachment.present?
  end

  def registered?(user)
    event_registrations.where(user: user).present?
  end

  def registration_canceled?(user)
    event_registrations.where(user: user, status_cd: :canceled).present?
  end

  def upcoming_event?
    end_date > Time.zone.now
  end
end
