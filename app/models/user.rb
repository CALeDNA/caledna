# frozen_string_literal: true

class User < ApplicationRecord
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

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

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

  validates :email, :username, :password, presence: true
end
