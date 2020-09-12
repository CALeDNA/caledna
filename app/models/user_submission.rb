# frozen_string_literal: true

class UserSubmission < ApplicationRecord
  has_one_attached :image
  belongs_to :user, optional: true

  validates :user_display_name, :title, :content, presence: true
  validate :image_validation
  validate :media_url_validation
  validate :guest_email_validation

  scope :approved, -> { where(approved: true) }

  private

  def guest_email_validation
    return if user_id.present?
    return if email.present?

    errors[:email] << "can't be blank"
  end

  def media_url_validation
    return if media_url.blank?
    # rubocop:disable Style/NumericPredicate
    return if (/^https?:\/\// =~ media_url) == 0
    # rubocop:enable Style/NumericPredicate

    errors[:media_url] << 'The media url must start with http:// or https://'
  end

  # rubocop:disable Metrics/AbcSize
  def image_validation
    return unless image.attached?

    if !%w[image/png image/jpg image/jpeg].include?(image.blob.content_type)
      errors[:image] << 'Image must be png, jpg, or jpeg.'
    elsif image.blob.byte_size > 10_000_000
      errors[:image] << 'Image must be under 10 MB.'
    end
  end
  # rubocop:enable Metrics/AbcSize
end
