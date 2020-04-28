# frozen_string_literal: true

require "administrate/base_dashboard"

class UserDashboard < Administrate::BaseDashboard
  ATTRIBUTE_TYPES = {
    event_registrations: Field::HasMany,
    events: Field::HasMany,
    id: Field::Number,
    email: Field::String,
    encrypted_password: Field::String,
    reset_password_token: Field::String,
    reset_password_sent_at: Field::DateTime,
    remember_created_at: Field::DateTime,
    sign_in_count: Field::Number,
    current_sign_in_at: Field::DateTime,
    last_sign_in_at: Field::DateTime,
    confirmation_token: Field::String,
    confirmed_at: Field::DateTime,
    confirmation_sent_at: Field::DateTime,
    unconfirmed_email: Field::String,
    created_at: Field::DateTime,
    updated_at: Field::DateTime,
    username: Field::String,
    name: Field::String,
    location: Field::String,
    age: Field::Number,
    gender_cd: Field::String,
    education_cd: Field::String,
    ethnicity: Field::String,
    conservation_experience: Field::Boolean,
    dna_experience: Field::Boolean,
    work_info: Field::Text,
    time_outdoors_cd: Field::String,
    occupation: Field::String,
    science_career_goals: Field::Text,
    environmental_career_goals: Field::Text,
    uc_affiliation: Field::Boolean,
    uc_campus: Field::String,
    caledna_source: Field::String,
    agree: Field::Boolean,
    can_contact: Field::Boolean,
  }.freeze

  COLLECTION_ATTRIBUTES = [
    :username,
    :email,
    :updated_at
  ].freeze

   SHOW_PAGE_ATTRIBUTES = [
    :id,
    :email,
    :username,
    :name,
    :location,
    :age,
    :gender_cd,
    :education_cd,
    :ethnicity,
    :conservation_experience,
    :dna_experience,
    :work_info,
    :time_outdoors_cd,
    :occupation,
    :science_career_goals,
    :environmental_career_goals,
    :uc_affiliation,
    :uc_campus,
    :caledna_source,
    :agree,
    :can_contact,
    :event_registrations,
    :sign_in_count,
    :last_sign_in_at,
    :created_at,
    :updated_at,
  ].freeze

  FORM_ATTRIBUTES = [
    :email,
    :username,
    :name,
    :location,
    :age,
    :gender_cd,
    :education_cd,
    :ethnicity,
    :conservation_experience,
    :dna_experience,
    :work_info,
    :time_outdoors_cd,
    :occupation,
    :science_career_goals,
    :environmental_career_goals,
    :uc_affiliation,
    :uc_campus,
    :caledna_source,
    :agree,
    :can_contact,
    :event_registrations,
  ].freeze

  def display_resource(user)
    user.username
  end
end
