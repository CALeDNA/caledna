# frozen_string_literal: true

class Researcher < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  # :registerable
  devise :database_authenticatable,
         :recoverable, :rememberable, :trackable, :validatable,
         :invitable, invite_for: 2.weeks

  has_many :extractions, dependent: :destroy, foreign_key: :processor_id

  as_enum :role, %i[sample_processor lab_manager director],
          map: :string

  scope :active, -> { where(active: true) }

  def self.select_options
    Researcher.active.all.map { |e| [e.username, e.id] }
  end

  def active_for_authentication?
    super && active?
  end

  def inactive_message
    'You are not allowed to log in.'
  end
end
