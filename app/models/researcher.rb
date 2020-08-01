# frozen_string_literal: true

class Researcher < ApplicationRecord
  include MultipleLoginFields

  RESEARCHER_ROLES = %i[superadmin director esie_postdoc researcher].freeze

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  # :registerable
  devise :database_authenticatable, :lockable,
         :recoverable, :rememberable, :trackable, :validatable,
         :invitable, invite_for: 2.weeks

  has_many :research_project_authors, as: :authorable
  has_many :research_projects, through: :research_project_authors

  as_enum :role, RESEARCHER_ROLES, map: :string

  scope :active, -> { where(active: true) }

  def self.select_options
    Researcher.active.all.map { |e| [e.username, e.id] }
  end

  def view_sidekiq?
    superadmin? || director? || esie_postdoc? || researcher?
  end

  def view_pghero?
    superadmin? || director?
  end

  # NOTE: allow admins to deactive accounts
  def active_for_authentication?
    super && active?
  end

  def inactive_message
    'You are not allowed to log in.'
  end

  # NOTE: Devise doesn't recognize self.find_for_database_authentication
  # when it is added to MultipleLoginFields as a ClassMethods
  def self.find_for_database_authentication(warden_conditions)
    custom_find_for_database_authentication(warden_conditions)
  end
end
