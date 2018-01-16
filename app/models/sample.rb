# frozen_string_literal: true

class Sample < ApplicationRecord
  include PgSearch
  multisearchable :against => [:bar_code, :latitude, :longitude]

  belongs_to :project
end
