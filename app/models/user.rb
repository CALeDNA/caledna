# frozen_string_literal: true

class User < ApplicationRecord
  include MultipleLoginFields

  # allow users to input custom value for "Other" form option
  attr_accessor :other

  ETHNICITY = [
    'White',
    'Hispanic/Latino',
    'Black/African American',
    'Asian/Pacific Islander',
    'Other'
  ].freeze

  CALEDNA_SOURCE = [
    'Advertisement',
    'Email/Newsletter',
    'Facebook',
    'Twitter',
    'Family/Friend',
    'College Professor',
    'Website/Search engine',
    'Other'
  ].freeze

  EXISTING_USERS = 231

  # Include default devise modules. Others available are:
  # :trackable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable, :confirmable,
         :recoverable, :rememberable, :validatable

  has_many :event_registrations
  has_many :events, through: :event_registrations
  has_many :survey_responses

  as_enum :gender, %i[female male other], map: :string
  as_enum :education, [
    'Some high school',
    'High school diploma or equivalent',
    'Some college',
    "Associate's degree",
    "Bachelor's degree",
    'Some graduate degree',
    "Master's degree",
    'Professional degree',
    'Doctorate'
  ], map: :string
  as_enum :time_outdoors, [
    '0-2 hours',
    '2-5 hours',
    '5-10 hours',
    '10-20 hours',
    '20-30 hours',
    '30+ hours'
  ], map: :string

  validates :agree, presence: true
  validates :username,
            :email,
            presence: true,
            uniqueness: { case_sensitive: false }
  validates_format_of :username, with: /^[a-zA-Z0-9_\.]*$/, multiline: true

  # NOTE: Devise doesn't recognize self.find_for_database_authentication
  # when it is added to MultipleLoginFields as a ClassMethods
  def self.find_for_database_authentication(warden_conditions)
    custom_find_for_database_authentication(warden_conditions)
  end

  protected

  # Override Devise logic for IP tracking
  # https://github.com/plataformatec/devise/blob/master/lib/devise/models/trackable.rb#L45
  def extract_ip_from(request); end
end
