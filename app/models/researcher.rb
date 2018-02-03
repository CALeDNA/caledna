# frozen_string_literal: true

class Researcher < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  # :registerable
  devise :database_authenticatable,
         :recoverable, :rememberable, :trackable, :validatable,
         :invitable, invite_for: 2.weeks

  has_many :samples, dependent: :destroy, foreign_key: :processor_id

  as_enum :role, %i[sample_processor lab_manager director],
          map: :string
end
